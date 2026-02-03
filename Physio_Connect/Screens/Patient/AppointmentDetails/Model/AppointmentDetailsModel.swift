//
//  AppointmentDetailsModel.swift
//  Physio_Connect
//
//  Created by user@8 on 02/01/26.
//
import Foundation

struct AppointmentDetailsModel {
    let physioName: String
    let ratingText: String
    let specializationText: String
    let feeText: String

    let dateTimeText: String
    let locationText: String
    let statusText: String

    var sessionNotes: String

    // Optional for later DB wiring
    let phoneNumber: String?
}
