//
//  BookingDraft.swift
//  Physio_Connect
//
//  Created by user@8 on 01/01/26.
//
import Foundation
struct BookingDraft {
    let physioID: UUID
    let physioName: String
    let slotID: UUID
    let slotStart: Date
    let slotEnd: Date

    let address: String
    let phone: String
    let notes: String?
    let serviceMode: String // "home"
}
