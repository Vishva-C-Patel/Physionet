//
//  PhysiotherapistCardModel.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//

import Foundation
import CoreLocation

struct PhysiotherapistCardModel: Identifiable {
    let id: UUID
    let name: String
    let gender: String?

    let rating: Double
    let reviewsCount: Int

    /// What you show in the “specialist” line (TEMP: place_of_work, later: specialization join)
    let specializationText: String

    /// Already formatted like "₹1000/hr"
    let feeText: String
    let profileImagePath: String?
    let profileImageVersion: String?

    let latitude: Double?
    let longitude: Double?

    /// e.g. "within 5 km"
    var distanceText: String

    mutating func updateDistance(from userLocation: CLLocation) {
        guard let lat = latitude, let lon = longitude else { return }
        let physioLocation = CLLocation(latitude: lat, longitude: lon)
        let meters = userLocation.distance(from: physioLocation)
        let km = meters / 1000.0
        let rounded = (km < 1) ? 1 : Int(round(km))
        distanceText = "within \(rounded) km"
    }
}
