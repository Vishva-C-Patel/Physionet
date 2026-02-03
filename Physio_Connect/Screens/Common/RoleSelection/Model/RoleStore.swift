//
//  RoleStore.swift
//  Physio_Connect
//
//  Created by user@8 on 07/01/26.
//
import Foundation

final class RoleStore {
    static let shared = RoleStore()
    private init() {}

    private let key = "physioconnect.selected_role"

    var currentRole: AppRole? {
        get {
            guard let raw = UserDefaults.standard.string(forKey: key) else { return nil }
            return AppRole(rawValue: raw)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue.rawValue, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }

    func clear() {
        currentRole = nil
    }
}

