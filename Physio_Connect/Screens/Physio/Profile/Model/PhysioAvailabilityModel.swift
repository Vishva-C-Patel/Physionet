//
//  PhysioAvailabilityModel.swift
//  Physio_Connect
//
//  Created by Codex on 08/01/26.
//
import Foundation
import Supabase

struct AvailabilitySaveResult {
    let createdSlots: Int
}

final class PhysioAvailabilityModel {
    private let client = SupabaseManager.shared.client

    func saveAvailability(
        physioID: UUID,
        day: Date,
        startTime: Date,
        endTime: Date,
        repeatWeekdays: [Int]
    ) async throws -> AvailabilitySaveResult {
        if repeatWeekdays.isEmpty {
            return try await createSingleDaySlots(
                physioID: physioID,
                day: day,
                startTime: startTime,
                endTime: endTime
            )
        }
        return try await createRecurringAvailability(
            physioID: physioID,
            day: day,
            startTime: startTime,
            endTime: endTime,
            repeatWeekdays: repeatWeekdays
        )
    }

    func createHourlySlots(physioID: UUID, day: Date, startTime: Date, endTime: Date) async throws -> AvailabilitySaveResult {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: day)

        let start = combine(day: dayStart, time: startTime, calendar: calendar)
        let end = combine(day: dayStart, time: endTime, calendar: calendar)

        guard end > start else {
            throw AvailabilityError(message: "End time must be later than start time.")
        }

        let weekday = calendar.component(.weekday, from: dayStart) - 1
        let startLocal = timeString(from: start)
        let endLocal = timeString(from: end)

        let template = AvailabilityTemplateUpsert(
            physio_id: physioID,
            weekday: weekday,
            start_local: startLocal,
            end_local: endLocal,
            slot_minutes: 60,
            is_active: true
        )

        _ = try await client
            .from("physio_availability_templates")
            .upsert(template, onConflict: "physio_id,weekday,start_local,end_local")
            .execute()

        try await generateSlotsForDay(physioID: physioID, day: dayStart)
        let counts = try await fetchSlotCounts(physioID: physioID, day: dayStart)
        return AvailabilitySaveResult(createdSlots: counts.total)
    }

    private func createRecurringAvailability(
        physioID: UUID,
        day: Date,
        startTime: Date,
        endTime: Date,
        repeatWeekdays: [Int]
    ) async throws -> AvailabilitySaveResult {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: day)

        let start = combine(day: dayStart, time: startTime, calendar: calendar)
        let end = combine(day: dayStart, time: endTime, calendar: calendar)

        guard end > start else {
            throw AvailabilityError(message: "End time must be later than start time.")
        }

        let startLocal = timeString(from: start)
        let endLocal = timeString(from: end)
        let templates = repeatWeekdays.map {
            AvailabilityTemplateUpsert(
                physio_id: physioID,
                weekday: $0,
                start_local: startLocal,
                end_local: endLocal,
                slot_minutes: 60,
                is_active: true
            )
        }

        _ = try await client
            .from("physio_availability_templates")
            .upsert(templates, onConflict: "physio_id,weekday,start_local,end_local")
            .execute()

        try await generateSlotsForDay(physioID: physioID, day: dayStart)
        let counts = try await fetchSlotCounts(physioID: physioID, day: dayStart)
        return AvailabilitySaveResult(createdSlots: counts.total)
    }

    private func createSingleDaySlots(
        physioID: UUID,
        day: Date,
        startTime: Date,
        endTime: Date
    ) async throws -> AvailabilitySaveResult {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: day)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            throw AvailabilityError(message: "Invalid day selected.")
        }

        let start = combine(day: dayStart, time: startTime, calendar: calendar)
        let end = combine(day: dayStart, time: endTime, calendar: calendar)

        guard end > start else {
            throw AvailabilityError(message: "End time must be later than start time.")
        }

        let totalMinutes = Int(end.timeIntervalSince(start) / 60)
        if totalMinutes % 60 != 0 {
            throw AvailabilityError(message: "Select a range in 60-minute blocks.")
        }

        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let existing: [SlotCountRow] = try await client
            .from("physio_availability_slots")
            .select("id,is_booked")
            .eq("physio_id", value: physioID.uuidString)
            .gte("start_time", value: f.string(from: dayStart))
            .lt("start_time", value: f.string(from: dayEnd))
            .execute()
            .value

        if existing.contains(where: { $0.is_booked == true }) {
            throw AvailabilityError(message: "This day has booked slots. Update availability on an open day.")
        }

        _ = try await client
            .from("physio_availability_slots")
            .delete()
            .eq("physio_id", value: physioID.uuidString)
            .gte("start_time", value: f.string(from: dayStart))
            .lt("start_time", value: f.string(from: dayEnd))
            .execute()

        var inserts: [AvailabilitySlotInsert] = []
        var cursor = start
        while cursor < end {
            guard let next = calendar.date(byAdding: .minute, value: 60, to: cursor) else { break }
            if next <= end {
                inserts.append(
                    AvailabilitySlotInsert(
                        physio_id: physioID,
                        start_time: f.string(from: cursor),
                        end_time: f.string(from: next),
                        is_booked: false
                    )
                )
            }
            cursor = next
        }

        if !inserts.isEmpty {
            _ = try await client
                .from("physio_availability_slots")
                .insert(inserts)
                .execute()
        }

        let counts = try await fetchSlotCounts(physioID: physioID, day: dayStart)
        return AvailabilitySaveResult(createdSlots: counts.total)
    }

    private func upsertDailySummary(physioID: UUID, day: Date, available: Int, total: Int) async throws {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone.current
        let dayString = df.string(from: day)

        let payload = SummaryUpsert(
            physio_id: physioID,
            day: dayString,
            available_count: available,
            total_slots: total
        )

        _ = try await client
            .from("physio_availability_calendar")
            .upsert(payload, onConflict: "physio_id,day")
            .execute()
    }

    private func combine(day: Date, time: Date, calendar: Calendar) -> Date {
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: 0, of: day) ?? day
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }

    private func generateSlotsForDay(physioID: UUID, day: Date) async throws {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone.current
        let dayString = df.string(from: day)

        _ = try await client
            .rpc(
                "generate_slots_for_range",
                params: [
                    "p_physio_id": physioID.uuidString,
                    "p_from": dayString,
                    "p_to": dayString,
                    "p_tz": TimeZone.current.identifier
                ]
            )
            .execute()
    }

    private func fetchSlotCounts(physioID: UUID, day: Date) async throws -> (available: Int, total: Int) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: day)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return (0, 0) }

        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let rows: [SlotCountRow] = try await client
            .from("physio_availability_slots")
            .select("id,is_booked")
            .eq("physio_id", value: physioID.uuidString)
            .gte("start_time", value: f.string(from: startOfDay))
            .lt("start_time", value: f.string(from: endOfDay))
            .execute()
            .value

        let total = rows.count
        let available = rows.filter { $0.is_booked == false }.count
        return (available, total)
    }
}

private struct AvailabilityTemplateUpsert: Encodable {
    let physio_id: UUID
    let weekday: Int
    let start_local: String
    let end_local: String
    let slot_minutes: Int
    let is_active: Bool
}

private struct AvailabilitySlotInsert: Encodable {
    let physio_id: UUID
    let start_time: String
    let end_time: String
    let is_booked: Bool
}

private struct SummaryRow: Decodable {
    let physio_id: UUID
    let day: String
    let available_count: Int?
    let total_slots: Int?
}

private struct SummaryUpsert: Encodable {
    let physio_id: UUID
    let day: String
    let available_count: Int
    let total_slots: Int
}

private struct SlotCountRow: Decodable {
    let id: UUID
    let is_booked: Bool?
}

private struct AvailabilityError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
