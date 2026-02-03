import Foundation

enum AppointmentStatus {
    case upcoming
    case completed
    case cancelled
    case cancelledByPhysio
}

struct Appointment {
    let id: UUID
    let doctorName: String
    let specialization: String
    let ratingText: String
    let dateText: String
    let timeText: String
    let status: AppointmentStatus
    var sessionNotes: String
    let phoneNumber: String?
    let locationText: String
    let feeText: String
    let profileImagePath: String?
    let profileImageVersion: String?
}
