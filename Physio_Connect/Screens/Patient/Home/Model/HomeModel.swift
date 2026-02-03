//
//  HomeModel.swift
//  Physio_Connect
//
//  Created by Ayush Rai on 31/12/25.
//
import Foundation

final class HomeModel {

    struct ProgressSummary {
        let painSeries: [Int]
        let adherenceSeries: [Int]
        let weeklyAdherencePercent: Int
        let painDeltaPercent: Int
        let averagePain: Double
    }

    static var emptyProgressSummary: ProgressSummary {
        ProgressSummary(
            painSeries: Array(repeating: 0, count: 7),
            adherenceSeries: Array(repeating: 0, count: 6),
            weeklyAdherencePercent: 0,
            painDeltaPercent: 0,
            averagePain: 0
        )
    }

    func fetchUpcomingAppointments() async throws -> [HomeUpcomingAppointment] {

        let session = try await SupabaseManager.shared.client.auth.session
        let userId = session.user.id

        struct ApptJoinRow: Decodable {
            let id: UUID
            let physio_id: UUID
            let service_mode: String
            let address_text: String?
            let status: String

            let physiotherapists: PhysioJoin
            let physio_availability_slots: SlotJoin

            struct PhysioJoin: Decodable {
                let name: String
                let consultation_fee: Double?
                let avg_rating: Double?
                let reviews_count: Int?
                let profile_image_path: String?
                let updated_at: String?
                let physio_specializations: [PhysioSpecJoin]?

                struct PhysioSpecJoin: Decodable {
                    let specializations: Specialization?
                    struct Specialization: Decodable {
                        let name: String
                    }
                }
            }
            struct SlotJoin: Decodable {
                let start_time: Date
                let end_time: Date
            }
        }

        let rows: [ApptJoinRow] = try await SupabaseManager.shared.client
            .from("appointments")
            .select("""
                id,
                physio_id,
                service_mode,
                address_text,
                status,
                physiotherapists(
                    name,
                    consultation_fee,
                    avg_rating,
                    reviews_count,
                    profile_image_path,
                    updated_at,
                    physio_specializations(
                        specializations(name)
                    )
                ),
                physio_availability_slots(start_time,end_time)
            """)
            .eq("customer_id", value: userId.uuidString)
            .or("status.eq.booked,status.eq.confirmed")
            .execute()
            .value
        let mapped = rows.compactMap { r -> HomeUpcomingAppointment? in
            guard r.physio_availability_slots.start_time > Date() else { return nil }
            let specialization = r.physiotherapists.physio_specializations?
                .compactMap { $0.specializations?.name }
                .first ?? "Physiotherapist Specialist"
            let feeText: String
            if let fee = r.physiotherapists.consultation_fee {
                feeText = "₹\(Int(fee))/hr"
            } else {
                feeText = "TBD"
            }
            let ratingText: String
            if let avg = r.physiotherapists.avg_rating, let count = r.physiotherapists.reviews_count {
                ratingText = "⭐️ \(String(format: "%.1f", avg)) | \(count) reviews"
            } else {
                ratingText = "N/A"
            }

            return HomeUpcomingAppointment(
                appointmentID: r.id,
                physioID: r.physio_id,
                physioName: r.physiotherapists.name,
                serviceMode: r.service_mode,
                specializationText: specialization,
                consultationFeeText: feeText,
                ratingText: ratingText,
                profileImagePath: r.physiotherapists.profile_image_path,
                profileImageVersion: r.physiotherapists.updated_at,
                startTime: r.physio_availability_slots.start_time,
                endTime: r.physio_availability_slots.end_time,
                address: r.address_text ?? "",
                status: r.status
            )
        }
        return mapped.sorted { $0.startTime < $1.startTime }
    }

    func fetchProgressSummary(programID: UUID?) async throws -> ProgressSummary {
        struct ProgressRow: Decodable {
            let program_id: UUID?
            let progress_date: String?
            let is_completed: Bool?
            let pain_level: Int?
        }

        let session = try await SupabaseManager.shared.client.auth.session
        let userId = session.user.id.uuidString

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -41, to: today) else {
            return ProgressSummary(
                painSeries: Array(repeating: 0, count: 7),
                adherenceSeries: Array(repeating: 0, count: 6),
                weeklyAdherencePercent: 0,
                painDeltaPercent: 0,
                averagePain: 0
            )
        }
        let startString = df.string(from: startDate)

        let rows: [ProgressRow] = try await SupabaseManager.shared.client
            .from("exercise_progress")
            .select("program_id, progress_date, is_completed, pain_level")
            .eq("customer_id", value: userId)
            .gte("progress_date", value: startString)
            .execute()
            .value
        let filteredRows = rows.filter { row in
            if let programID {
                return row.program_id == programID
            }
            return row.program_id == nil
        }

        var painSeries: [Int] = []
        for i in (0...6).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dayString = df.string(from: day)
            let dayRows = filteredRows.filter { $0.progress_date == dayString }
            let pains = dayRows.compactMap { $0.pain_level }
            let painAvg = pains.isEmpty ? 0 : Int(Double(pains.reduce(0, +)) / Double(pains.count))
            painSeries.append(painAvg)
        }

        var adherenceSeries: [Int] = []
        for i in (0...5).reversed() {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: today) else { continue }
            let weekRange = calendar.dateInterval(of: .weekOfYear, for: weekStart)
            let weekRows = filteredRows.filter { row in
                guard let dateString = row.progress_date, let date = df.date(from: dateString) else { return false }
                guard let weekRange else { return false }
                return weekRange.contains(date)
            }
            let completed = weekRows.filter { $0.is_completed == true }.count
            let total = weekRows.count
            let adherence = total == 0 ? 0 : Int(Double(completed) / Double(total) * 100.0)
            adherenceSeries.append(adherence)
        }

        let weeklyTotal = adherenceSeries.last ?? 0
        let weeklyAdherencePercent = weeklyTotal
        let firstPain = painSeries.first ?? 0
        let lastPain = painSeries.last ?? 0
        let painDeltaPercent = firstPain == 0 ? 0 : Int(Double(lastPain - firstPain) / Double(firstPain) * 100.0)
        let avgPain = painSeries.isEmpty ? 0 : Double(painSeries.reduce(0, +)) / Double(painSeries.count)

        return ProgressSummary(
            painSeries: painSeries,
            adherenceSeries: adherenceSeries,
            weeklyAdherencePercent: weeklyAdherencePercent,
            painDeltaPercent: painDeltaPercent,
            averagePain: avgPain
        )
    }
}
