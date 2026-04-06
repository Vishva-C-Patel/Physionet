//
//  PhysioAppointmentsModel.swift
//  Physio_Connect
//
//  Created by user@8 on 11/01/26.
//

import Foundation
import Supabase

struct PhysioAppointment {
    let id: UUID
    let status: String
    let serviceMode: String
    let addressText: String?
    let createdAt: Date
    let slot: SlotRow?
    let customer: CustomerRow?

    struct SlotRow {
        let startTime: Date
        let endTime: Date?
    }

    struct CustomerRow {
        let id: UUID
        let fullName: String?
        let email: String?
        let phone: String?
        let location: String?
    }
}

final class PhysioAppointmentsModel {
    private let client = SupabaseManager.shared.client

    func fetchAppointments(physioID: String) async throws -> [PhysioAppointment] {
        let rows: [AppointmentJoinedRow] = try await client
            .from("appointments")
            .select("""
                id,
                status,
                service_mode,
                address_text,
                created_at,
                slot:physio_availability_slots(
                    start_time,
                    end_time
                ),
                customer:customers(
                    id,
                    full_name,
                    email,
                    phone,
                    location
                )
            """)
            .eq("physio_id", value: physioID)
            .order("created_at", ascending: false)
            .execute()
            .value

        let normalizedRows = await completePastAppointmentsIfNeeded(rows: rows)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let alternateFormatter = ISO8601DateFormatter()
        alternateFormatter.formatOptions = [.withInternetDateTime]

        return normalizedRows.map { row in
            let createDate = (row.created_at.flatMap { formatter.date(from: $0) ?? alternateFormatter.date(from: $0) }) ?? Date()
            
            var slotModel: PhysioAppointment.SlotRow? = nil
            if let slot = row.slot, let startText = slot.start_time, let startDate = formatter.date(from: startText) ?? alternateFormatter.date(from: startText) {
                let endDate = slot.end_time.flatMap { formatter.date(from: $0) ?? alternateFormatter.date(from: $0) }
                slotModel = PhysioAppointment.SlotRow(startTime: startDate, endTime: endDate)
            }
            
            return PhysioAppointment(
                id: row.id,
                status: row.status,
                serviceMode: row.service_mode ?? "session",
                addressText: row.address_text,
                createdAt: createDate,
                slot: slotModel,
                customer: row.customer.map {
                    PhysioAppointment.CustomerRow(
                        id: $0.id,
                        fullName: $0.full_name,
                        email: $0.email,
                        phone: $0.phone,
                        location: $0.location
                    )
                }
            )
        }
    }

    func updateStatus(appointmentID: UUID, status: String) async throws {
        let finalStatus = try await updateStatusWithFallback(appointmentID: appointmentID, status: status)
        if finalStatus == "cancelled" || finalStatus == "cancelled_by_physio" {
            if let slotID = try await fetchSlotID(for: appointmentID) {
                try await updateSlotBooking(slotID: slotID, isBooked: false)
            }
        }
    }

    private func updateStatusWithFallback(appointmentID: UUID, status: String) async throws -> String {
        do {
            _ = try await client
                .from("appointments")
                .update(["status": status])
                .eq("id", value: appointmentID.uuidString)
                .execute()
            return status
        } catch {
            guard status == "cancelled_by_physio" else { throw error }
            _ = try await client
                .from("appointments")
                .update(["status": "cancelled"])
                .eq("id", value: appointmentID.uuidString)
                .execute()
            return "cancelled"
        }
    }

    private func fetchSlotID(for appointmentID: UUID) async throws -> UUID? {
        struct SlotRow: Decodable { let slot_id: UUID? }
        let row: SlotRow = try await client
            .from("appointments")
            .select("slot_id")
            .eq("id", value: appointmentID.uuidString)
            .single()
            .execute()
            .value
        return row.slot_id
    }

    private func updateSlotBooking(slotID: UUID, isBooked: Bool) async throws {
        _ = try await client
            .from("physio_availability_slots")
            .update(["is_booked": isBooked])
            .eq("id", value: slotID.uuidString)
            .execute()
    }

    // fetchSlotsByID and fetchCustomersByID removed

    private func completePastAppointmentsIfNeeded(rows: [AppointmentJoinedRow]) async -> [AppointmentJoinedRow] {
        let now = Date()
        var updatedRows: [AppointmentJoinedRow] = []
        updatedRows.reserveCapacity(rows.count)

        for row in rows {
            let status = row.status.lowercased()
            let isTerminal = status == "completed" || status == "cancelled" || status == "cancelled_by_physio"
            guard !isTerminal, let slot = row.slot else {
                updatedRows.append(row)
                continue
            }

            guard let dueDate = parseDate(slot.end_time) ?? parseDate(slot.start_time), dueDate <= now else {
                updatedRows.append(row)
                continue
            }

            do {
                _ = try await updateStatusWithFallback(appointmentID: row.id, status: "completed")
                updatedRows.append(AppointmentJoinedRow(
                    id: row.id,
                    status: "completed",
                    service_mode: row.service_mode,
                    address_text: row.address_text,
                    created_at: row.created_at,
                    slot: row.slot,
                    customer: row.customer
                ))
            } catch {
                updatedRows.append(row)
            }
        }

        return updatedRows
    }
    
    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) { return date }
        
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dateString)
    }
}


// Private isolated query DTOs removed in favor of DTOs underneath

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

// MARK: - Joined Row DTO Models
private struct AppointmentJoinedRow: Decodable {
    let id: UUID
    let status: String
    let service_mode: String?
    let address_text: String?
    let created_at: String? // Decode as String to avoid parsing issues
    
    let slot: SlotRow?
    let customer: CustomerRow?
    
    struct SlotRow: Decodable {
        let start_time: String?
        let end_time: String?
    }
}

