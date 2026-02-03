//
//  CreateAccountModel.swift
//  Physio_Connect
//
//  Created by user@8 on 01/01/26.
//


import Foundation

struct AppointmentDraft {
    let dateText: String      // e.g. "April 2025 20"
    let timeText: String      // e.g. "9:00 AM"
    let therapistName: String // e.g. "Dr. Ananya Sharma"
    let addressText: String   // e.g. "123 Oak Street..."
}

struct CreateAccountModel {
    let appointment: AppointmentDraft
}
