//
//  PaymentModel.swift
//  Physio_Connect
//
//  Created by user@8 on 01/01/26.
//
import Foundation

struct PaymentModel {

    let draft: BookingDraft

    // pricing (dummy – change later)
    let sessionFee: Int
    let homeVisitFee: Int
    let platformFee: Int

    var total: Int { sessionFee + homeVisitFee + platformFee }

    init(draft: BookingDraft) {
        self.draft = draft
        self.sessionFee = 499
        self.homeVisitFee = 199
        self.platformFee = 29
    }

    func formattedDateTime() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"

        let tf = DateFormatter()
        tf.dateFormat = "h:mm a"

        return "\(df.string(from: draft.slotStart)) at \(tf.string(from: draft.slotStart))"
    }
}

