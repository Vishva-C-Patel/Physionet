//
//  HomeUpcomingAppointment.swift
//  Physio_Connect
//
//  Created by user@8 on 01/01/26.
//
import Foundation

struct HomeUpcomingAppointment {

    let appointmentID: UUID
    let physioID: UUID

    let physioName: String
    let serviceMode: String
    let specializationText: String
    let consultationFeeText: String
    let ratingText: String
    let profileImagePath: String?
    let profileImageVersion: String?

    let startTime: Date
    let endTime: Date

    let address: String
    let status: String
}
