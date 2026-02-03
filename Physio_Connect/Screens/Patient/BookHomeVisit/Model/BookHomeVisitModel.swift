//
//  BookHomeVisitModel.swift
//  Physio_Connect
//
//  Created by user@8 on 31/12/25.
//
import Foundation

struct PhysioSummaryVM {
    let id: UUID
    let name: String
    let specializationText: String
    let ratingText: String
    let feeText: String
}

struct SlotRow: Decodable {
    let id: UUID
    let physio_id: UUID
    let start_time: Date
    let end_time: Date
    let is_booked: Bool
}

struct AppointmentInsertRow: Encodable {
    let user_id: UUID
    let physio_id: UUID
    let slot_id: UUID
    let service_type: String          // "home"
    let address: String
    let phone: String
    let notes: String?
    let status: String               // "booked"
    let appointment_start: Date
    let appointment_end: Date
}

