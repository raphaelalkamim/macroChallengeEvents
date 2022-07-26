//
//  UserDefaultManager.swift
//  macroChallengeApp
//
//  Created by Beatriz Duque on 10/11/22.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    var nextTrip: String? {
        didSet {
            UserDefaults(suiteName: "group.wimbiApp")?.set(nextTrip, forKey: "nextTrip")
        }
    }
    var countdown: String? {
        didSet {
            UserDefaults(suiteName: "group.wimbiApp")?.set(countdown, forKey: "countdown")
        }
    }
    private init() {
        self.nextTrip = UserDefaults(suiteName: "group.wimbiApp")?.object(forKey: "nextTrip") as? String
        self.countdown = UserDefaults(suiteName: "group.wimbiApp")?.object(forKey: "countdown") as? String
    }
}
