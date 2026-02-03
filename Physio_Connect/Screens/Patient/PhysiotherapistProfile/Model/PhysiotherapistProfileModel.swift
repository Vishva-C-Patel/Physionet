//
//  PhysiotherapistProfileModel.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//

import Foundation
import CoreLocation

struct PhysiotherapistProfileModel {
    let id: UUID
    let name: String
    let about: String
    let specializationText: String
    let consultationFeeText: String
    let ratingText: String
    //let distanceText: String
    
    let servicePlaceText: String

    let patientsText: String
    let experienceText: String
    let ratingNumberText: String
    let reviewsCountText: String

    let reviews: [PhysioReviewRow]

    static func build(from physio: Physiotherapist,
                      specializations: [String],
                      preloadDistanceText: String?,
                      userLocation: CLLocation?,
                      reviews: [PhysioReviewRow]) -> PhysiotherapistProfileModel {

        let fee = Int(physio.consultation_fee ?? 0)
        let feeText = "₹\(fee)/hr"
        
        let place = (physio.location_text?.isEmpty == false)
            ? physio.location_text!
            : ((physio.place_of_work?.isEmpty == false) ? physio.place_of_work! : "Service location not available")

        
        let avg = physio.avg_rating ?? 0
        let count = physio.reviews_count ?? 0
        let ratingText = "⭐️ \(String(format: "%.1f", avg)) | \(count) reviews"

        let specialization = specializations.first
            ?? (physio.place_of_work?.isEmpty == false ? physio.place_of_work! : "Physiotherapy specialist")

        let about = (physio.about?.isEmpty == false)
            ? physio.about!
            : "This physiotherapist has not added an about section yet."

        let patients = physio.patients_served ?? 0
        let years = physio.years_experience ?? 0

        // distance
        /*var distText = preloadDistanceText ?? "within 5 km"
        if let u = userLocation, let lat = physio.latitude, let lon = physio.longitude {
            let p = CLLocation(latitude: lat, longitude: lon)
            let km = u.distance(from: p) / 1000.0
            let rounded = (km < 1) ? 1 : Int(round(km))
            distText = "within \(rounded) km"
        }*/

        return .init(
            id: physio.id,
            name: physio.name,
            about: about,
            specializationText: specialization,
            consultationFeeText: feeText,
            ratingText: ratingText,

            servicePlaceText: place,   // ✅ here

            patientsText: "\(patients)+\nPatients",
            experienceText: "\(years)+\nExperience",
            ratingNumberText: "\(Int(round(avg)))\nRating",
            reviewsCountText: "\(count)\nReviews",
            reviews: reviews
        )

    }
}
