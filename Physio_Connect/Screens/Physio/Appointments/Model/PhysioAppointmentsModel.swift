//
//  PhysioAppointmentsModel.swift
//  Physio_Connect
//
//  Created by Codex on 11/01/26.
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
            .order("created_at", ascending: false)
            .execute()
            .value

        let slotsByID = try await fetchSlotsByID(ids: rows.compactMap(\.slot_id))
        let customersByID = try await fetchCustomersByID(ids: rows.compactMap(\.customer_id))
        let normalizedRows = await completePastAppointmentsIfNeeded(rows: rows, slotsByID: slotsByID)

        return normalizedRows.map { row in
            let slot = row.slot_id.flatMap { slotsByID[$0] }
            let customer = row.customer_id.flatMap { customersByID[$0] }
            return PhysioAppointment(
                id: row.id,
                status: row.status,
                serviceMode: row.service_mode ?? "session",
                addressText: row.address_text,
                createdAt: row.created_at,
                slot: slot.map {
                    PhysioAppointment.SlotRow(startTime: $0.start_time, endTime: $0.end_time)
                },
                customer: customer.map {
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

    private func completePastAppointmentsIfNeeded(rows: [AppointmentRow],
                                                  slotsByID: [UUID: SlotRowFlat]) async -> [AppointmentRow] {
        let now = Date()
        var updatedRows: [AppointmentRow] = []
        updatedRows.reserveCapacity(rows.count)

        for row in rows {
            let status = row.status.lowercased()
            let isTerminal = status == "completed" || status == "cancelled" || status == "cancelled_by_physio"
            guard !isTerminal, let slotID = row.slot_id, let slot = slotsByID[slotID] else {
                updatedRows.append(row)
                continue
            }

            let dueDate = slot.end_time ?? slot.start_time
            guard dueDate <= now else {
                updatedRows.append(row)
                continue
            }

            do {
                _ = try await updateStatusWithFallback(appointmentID: row.id, status: "completed")
                updatedRows.append(AppointmentRow(
                    id: row.id,
                    status: "completed",
                    service_mode: row.service_mode,
                    address_text: row.address_text,
                    created_at: row.created_at,
                    slot_id: row.slot_id,
                    customer_id: row.customer_id
                ))
            } catch {
                updatedRows.append(row)
            }
        }

        return updatedRows
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
