//
//  LocationService.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//
import Foundation
import CoreLocation

final class LocationService: NSObject, CLLocationManagerDelegate {

    static let shared = LocationService()
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    var lastLocation: CLLocation?
    var onLocationUpdate: ((String, CLLocation?) -> Void)?

    // MARK: - Public
    func requestLocation() {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }

        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()

        case .denied, .restricted:
            onLocationUpdate?("Location unavailable", nil)

        @unknown default:
            onLocationUpdate?("Location unavailable", nil)
        }
    }

    // MARK: - Auth changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()

        case .denied, .restricted:
            onLocationUpdate?("Location unavailable", nil)

        case .notDetermined:
            break

        @unknown default:
            onLocationUpdate?("Location unavailable", nil)
        }
    }

    // MARK: - Location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else {
            onLocationUpdate?("Location unavailable", nil)
            return
        }

        lastLocation = loc

        geocoder.reverseGeocodeLocation(loc) { [weak self] placemarks, error in
            // If reverse geocode fails, still send location so distance can be computed
            let city = placemarks?.first?.locality
                ?? placemarks?.first?.administrativeArea
                ?? "Your location"

            self?.onLocationUpdate?(city, loc)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // If it's a transient error, keep it graceful.
        onLocationUpdate?("Location unavailable", nil)
    }
}
