//
//  FCMTokenStore.swift
//  BookBetween
//

import Foundation

nonisolated protocol FCMTokenStoreProtocol {
    func save(_ token: String)
    func token() -> String?
}

nonisolated final class FCMTokenStore: FCMTokenStoreProtocol {
    private enum Key {
        static let fcmToken = "notification.fcmToken"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func save(_ token: String) {
        userDefaults.set(token, forKey: Key.fcmToken)
    }

    func token() -> String? {
        userDefaults.string(forKey: Key.fcmToken)
    }
}
