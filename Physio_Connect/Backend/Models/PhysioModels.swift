//
//  PhysioModels.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//


import Foundation

struct Physiotherapist: Decodable {
    let id: UUID
    let name: String

    let gender: String?
    let about: String?
    let years_experience: Int?
    let place_of_work: String?
    let consultation_fee: Double?

    let latitude: Double?
    let longitude: Double?

    let location_text: String?
    let patients_served: Int?

    let avg_rating: Double?
    let reviews_count: Int?
    let profile_image_path: String?

    let created_at: String?
    let updated_at: String?
}

// JOIN table: physio_specializations -> embedded specializations(name)
struct PhysioSpecializationRow: Decodable {
    let physio_id: UUID
    let specializations: SpecializationName?
}

struct SpecializationName: Decodable {
    let name: String
}

// Reviews table: physio_reviews
struct PhysioReviewRow: Decodable {
    let id: UUID
    let physio_id: UUID
    let reviewer_name: String
    let rating: Int
    let review_text: String?
    let created_at: String?
}
