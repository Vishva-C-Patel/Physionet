//
//  PhysioEditProfileViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 09/01/26.
//

import UIKit
import CoreLocation

final class PhysioEditProfileViewController: UIViewController {

    private let editView = PhysioEditProfileView()
    private let model = PhysioProfileModel()
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    var onProfileUpdated: (() -> Void)?

    override func loadView() { view = editView }

    override func viewDidLoad() {
        super.viewDidLoad()
        enableTapToDismissKeyboard()
        UITheme.applyNativeNavBar(to: self, title: "Edit Profile")
        let saveItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = saveItem
        bind()
        loadProfile()
    }

    @objc private func saveTapped() {
        saveProfile()
    }

    private func bind() {
        // Form events are handled natively or internally now
    }

    private func loadProfile() {
        Task {
            do {
                let data = try await model.fetchEditProfile()
                await MainActor.run {
                    self.editView.apply(data)
                    self.requestCurrentLocationIfNeeded()
                }
            } catch {
                await MainActor.run { self.showError("Failed to load profile.") }
            }
        }
    }

    private func saveProfile() {
        let input: PhysioProfileModel.UpdateInput
        do {
            input = try editView.validatedInput()
        } catch {
            showError(error.localizedDescription)
            return
        }

        navigationItem.rightBarButtonItem?.isEnabled = false
        editView.setSaving(true)
        Task {
            do {
                if !editView.hasCoordinates() {
                    let address = editView.currentAddress()
                    if let coordinate = await geocodeAddress(address) {
                        editView.setCoordinates(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    }
                }
                
                // Re-fetch input to capture any newly geocoded coordinates
                let finalInput = try editView.validatedInput()
                
                try await model.updateProfile(finalInput)
                await MainActor.run {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.editView.setSaving(false)
                    self.onProfileUpdated?()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("❌ Physio profile save error:", error)
                await MainActor.run {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.editView.setSaving(false)
                    self.showError(error.localizedDescription)
                }
            }
        }
    }

    private func showError(_ message: String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

extension PhysioEditProfileViewController: CLLocationManagerDelegate {
    private func requestCurrentLocationIfNeeded() {
        guard !editView.hasCoordinates() else { return }
        locationManager.delegate = self
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            return
        @unknown default:
            showError("Unable to access location.")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        editView.setCoordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self, let place = placemarks?.first else { return }
            let city = place.locality
            let area = place.subLocality
            let region = place.administrativeArea
            let parts = [area, city, region].compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            if !parts.isEmpty {
                self.editView.setLocationText(parts.joined(separator: ", "))
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        return
    }

    private func geocodeAddress(_ address: String) async -> CLLocationCoordinate2D? {
        let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return await withCheckedContinuation { continuation in
            geocoder.geocodeAddressString(trimmed) { placemarks, _ in
                continuation.resume(returning: placemarks?.first?.location?.coordinate)
            }
        }
    }
}
