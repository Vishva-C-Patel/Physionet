//
//  AppointmentStore.swift
//  Physio_Connect
//
//  Created by user@8 on 01/01/26.
//
import Foundation

final class AppointmentStore {
    static let shared = AppointmentStore()

    private init() {}

    struct Upcoming {
        let physioName: String
        let date: Date
        let address: String
    }

    private(set) var upcoming: Upcoming?

    func setUpcoming(physioName: String, date: Date, address: String) {
        upcoming = Upcoming(physioName: physioName, date: date, address: address)
    }

    func clear() { upcoming = nil }
}

