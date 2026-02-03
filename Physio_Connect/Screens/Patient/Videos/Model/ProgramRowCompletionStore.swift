//
//  ProgramRowCompletionStore.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import Foundation

enum ProgramRowCompletionStore {
    static func completionMap(programID: UUID) -> [String: String] {
        let defaults = UserDefaults.standard
        let key = storageKey(for: programID)
        if let values = defaults.dictionary(forKey: key) as? [String: String] {
            return values
        }
        if let legacy = defaults.array(forKey: key) as? [String] {
            let today = todayString()
            let upgraded = Dictionary(uniqueKeysWithValues: legacy.map { ($0, today) })
            defaults.set(upgraded, forKey: key)
            return upgraded
        }
        return [:]
    }

    static func add(rowKey: String, programID: UUID, completionDate: String) {
        var map = completionMap(programID: programID)
        map[rowKey] = completionDate
        save(map, programID: programID)
    }

    private static func save(_ map: [String: String], programID: UUID) {
        let defaults = UserDefaults.standard
        let key = storageKey(for: programID)
        defaults.set(map, forKey: key)
    }

    private static func storageKey(for programID: UUID) -> String {
        "completed_program_rows.\(programID.uuidString)"
    }

    private static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
