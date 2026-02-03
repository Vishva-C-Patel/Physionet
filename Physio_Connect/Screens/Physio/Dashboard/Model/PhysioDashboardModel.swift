//
//  PhysioDashboardModel.swift
//  Physio_Connect
//
//  Created by Codex on 08/01/26.
//
import Foundation
import Supabase

struct PhysioDashboardSummary {
    let todaySessions: Int
    let upcomingAppointments: Int
    let activePrograms: Int
}

struct PhysioUpcomingSession {
    let title: String
    let patientName: String
    let timeText: String
    let locationText: String
}

struct PhysioPatientRow {
    let name: String
    let contactLine: String
    let locationLine: String
}

final class PhysioDashboardModel {
    private let client = SupabaseManager.shared.client

    func resolvePhysioID() async throws -> String {
        let session = try await client.auth.session
        let userID = session.user.id.uuidString

        struct Row: Decodable { let id: UUID }

        let direct: [Row] = try await client
            .from("physiotherapists")
            .select("id")
            .eq("id", value: userID)
            .limit(1)
            .execute()
            .value

        if let match = direct.first {
            return match.id.uuidString
        }

        guard let email = session.user.email?.lowercased() else {
            return userID
        }

        let byEmail: [Row] = try await client
            .from("physiotherapists")
            .select("id")
            .eq("email", value: email)
            .order("updated_at", ascending: false)
            .limit(1)
            .execute()
            .value

        return byEmail.first?.id.uuidString ?? userID
    }

    func fetchSummary(physioID: String) async throws -> PhysioDashboardSummary {
        async let todayCount = fetchTodaySessionsCount(physioID: physioID)
        async let upcomingCount = fetchUpcomingSessionsCount(physioID: physioID)
        async let programCount = fetchActiveProgramsCount(physioID: physioID)

        return PhysioDashboardSummary(
            todaySessions: try await todayCount,
            upcomingAppointments: try await upcomingCount,
            activePrograms: try await programCount
        )
    }

    func fetchUpcomingSessions(physioID: String, limit: Int = 6) async throws -> [PhysioUpcomingSession] {
        let rows: [AppointmentRow] = try await client
            .from("appointments")
            .select("""
                id,
                status,
                service_mode,
                address_text,
                created_at,
                slot_id,
                customer_id
            """)
            .eq("physio_id", value: physioID)
            .or("status.eq.booked,status.eq.confirmed,status.eq.scheduled")
            .order("created_at", ascending: false)
            .execute()
            .value
        let slotsByID = try await fetchSlotsByID(ids: rows.compactMap(\.slot_id))
        let customersByID = try await fetchCustomersByID(ids: rows.compactMap(\.customer_id))

        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"

        let upcoming = rows.compactMap { row -> (Date, PhysioUpcomingSession)? in
            let slot = row.slot_id.flatMap { slotsByID[$0] }
            let customer = row.customer_id.flatMap { customersByID[$0] }
            let start = slot?.start_time
            let created = row.created_at
            if let start {
                if start < now && !Calendar.current.isDateInToday(start) { return nil }
            } else {
                if created < now && !Calendar.current.isDateInToday(created) { return nil }
            }

            let timeText: String
            let sortDate: Date
            if let start {
                let end = slot?.end_time
                let minutes = max(1, Int((end?.timeIntervalSince(start) ?? 0) / 60))
                let isToday = Calendar.current.isDateInToday(start)
                let dayText = isToday ? "Today" : dayFormatter.string(from: start)
                timeText = "\(dayText) • \(formatter.string(from: start)) • \(minutes) mins"
                sortDate = start
            } else {
                let isToday = Calendar.current.isDateInToday(created)
                let dayText = isToday ? "Today" : dayFormatter.string(from: created)
                timeText = "\(dayText) • Time TBD"
                sortDate = created
            }

            let patientName = customer?.full_name?.nilIfEmpty ?? "Patient"
            let mode = row.service_mode?.nilIfEmpty ?? "Session"
            let location = row.address_text?.nilIfEmpty ?? customer?.location?.nilIfEmpty ?? "Location TBD"
            let locationText = "Mode: \(mode.capitalized) • \(location)"

            let session = PhysioUpcomingSession(
                title: "\(mode.capitalized) Session",
                patientName: "Patient: \(patientName)",
                timeText: timeText,
                locationText: locationText
            )
            return (sortDate, session)
        }

        return upcoming
            .sorted { $0.0 < $1.0 }
            .prefix(limit)
            .map { $0.1 }
    }

    func fetchPatients(physioID: String, limit: Int = 12) async throws -> [PhysioPatientRow] {
        let rows: [AppointmentCustomerRow] = try await client
            .from("appointments")
            .select("""
                customer_id,
                created_at
            """)
            .eq("physio_id", value: physioID)
            .order("created_at", ascending: false)
            .limit(150)
            .execute()
            .value

        let customersByID = try await fetchCustomersByID(ids: rows.compactMap(\.customer_id))

        var seen = Set<UUID>()
        var patients: [PhysioPatientRow] = []
        for row in rows {
            guard let id = row.customer_id, let customer = customersByID[id] else { continue }
            if seen.contains(customer.id) { continue }
            seen.insert(customer.id)
            let name = customer.full_name?.nilIfEmpty ?? "Patient"
            let contact = customer.phone?.nilIfEmpty ?? customer.email?.nilIfEmpty ?? "No contact provided"
            let location = customer.location?.nilIfEmpty ?? "Location unavailable"
            patients.append(PhysioPatientRow(name: name, contactLine: contact, locationLine: location))
            if patients.count >= limit { break }
        }
        return patients
    }

    private func fetchTodaySessionsCount(physioID: String) async throws -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return 0 }

        let rows: [CountRow] = try await client
            .from("appointments")
            .select("""
                id,
                status,
                created_at,
                slot:physio_availability_slots!appointments_slot_id_fkey(
                    start_time
                )
            """)
            .eq("physio_id", value: physioID)
            .or("status.eq.booked,status.eq.confirmed,status.eq.scheduled")
            .execute()
            .value

        return rows.filter { row in
            if let slot = row.slot {
                return slot.start_time >= start && slot.start_time < end
            }
            return Calendar.current.isDate(row.created_at, inSameDayAs: start)
        }.count
    }

    private func fetchUpcomingSessionsCount(physioID: String) async throws -> Int {
        let rows: [CountRow] = try await client
            .from("appointments")
            .select("""
                id,
                status,
                created_at,
                slot:physio_availability_slots!appointments_slot_id_fkey(
                    start_time
                )
            """)
            .eq("physio_id", value: physioID)
            .or("status.eq.booked,status.eq.confirmed,status.eq.scheduled")
            .execute()
            .value

        let now = Date()
        return rows.filter { row in
            if let slot = row.slot {
                return slot.start_time >= now || Calendar.current.isDateInToday(slot.start_time)
            }
            return Calendar.current.isDateInToday(row.created_at)
        }.count
    }

    private func fetchActiveProgramsCount(physioID: String) async throws -> Int {
        let rows: [ProgramRow] = try await client
            .from("physio_programs")
            .select("id,is_active")
            .eq("physio_id", value: physioID)
            .eq("is_active", value: true)
            .execute()
            .value
        return rows.count
    }

    private func fetchSlotsByID(ids: [UUID]) async throws -> [UUID: SlotRowFlat] {
        let unique = Array(Set(ids))
        guard !unique.isEmpty else { return [:] }
        let rows: [SlotRowFlat] = try await client
            .from("physio_availability_slots")
            .select("id,start_time,end_time")
            .in("id", values: unique.map { $0.uuidString })
            .execute()
            .value
        return Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0) })
    }

    private func fetchCustomersByID(ids: [UUID]) async throws -> [UUID: CustomerRow] {
        let unique = Array(Set(ids))
        guard !unique.isEmpty else { return [:] }
        let rows: [CustomerRow] = try await client
            .from("customers")
            .select("id,full_name,email,phone,location")
            .in("id", values: unique.map { $0.uuidString })
            .execute()
            .value
        return Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0) })
    }

    private func isoString(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}

private struct AppointmentRow: Decodable {
    let id: UUID
    let status: String
    let service_mode: String?
    let address_text: String?
    let created_at: Date
    let slot_id: UUID?
    let customer_id: UUID?
}

private struct AppointmentCustomerRow: Decodable {
    let customer_id: UUID?
    let created_at: Date?
}

private struct SlotRowFlat: Decodable {
    let id: UUID
    let start_time: Date
    let end_time: Date?
}

private struct CustomerRow: Decodable {
    let id: UUID
    let full_name: String?
    let email: String?
    let phone: String?
    let location: String?

    enum CodingKeys: String, CodingKey {
        case id
        case full_name
        case email
        case phone
        case location
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        full_name = try container.decodeIfPresent(String.self, forKey: .full_name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        phone = Self.decodeFlexibleString(from: container, forKey: .phone)
    }

    private static func decodeFlexibleString(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> String? {
        if let value = try? container.decodeIfPresent(String.self, forKey: key) {
            return value
        }
        if let intValue = try? container.decodeIfPresent(Int.self, forKey: key) {
            return String(intValue)
        }
        if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: key) {
            if doubleValue.rounded() == doubleValue {
                return String(Int(doubleValue))
            }
            return String(doubleValue)
        }
        return nil
    }
}

private struct CountRow: Decodable {
    let id: UUID
    let created_at: Date
    let slot: SlotRow?

    struct SlotRow: Decodable {
        let start_time: Date
    }
}

private struct ProgramRow: Decodable {
    let id: UUID
    let is_active: Bool?
}

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
