//
//  AuthSessionStore.swift
//  BookBetween
//

import Foundation

nonisolated protocol AuthSessionStoreProtocol {
    func saveMemberStatus(_ status: MemberStatus)
    func memberStatus() -> MemberStatus?
    func saveScheduledDeletionAt(_ value: String?)
    func scheduledDeletionAt() -> String?
    func clear()
}

nonisolated final class AuthSessionStore: AuthSessionStoreProtocol {
    private enum Key {
        static let memberStatus = "auth.memberStatus"
        static let scheduledDeletionAt = "auth.scheduledDeletionAt"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveMemberStatus(_ status: MemberStatus) {
        userDefaults.set(
            status.rawValue,
            forKey: Key.memberStatus
        )
    }

    func memberStatus() -> MemberStatus? {
        guard let rawValue = userDefaults.string(
            forKey: Key.memberStatus
        ) else {
            return nil
        }

        return MemberStatus(rawValue: rawValue)
    }

    func saveScheduledDeletionAt(_ value: String?) {
        if let value {
            userDefaults.set(
                value,
                forKey: Key.scheduledDeletionAt
            )
        } else {
            userDefaults.removeObject(
                forKey: Key.scheduledDeletionAt
            )
        }
    }

    func scheduledDeletionAt() -> String? {
        userDefaults.string(
            forKey: Key.scheduledDeletionAt
        )
    }

    func clear() {
        userDefaults.removeObject(forKey: Key.memberStatus)
        userDefaults.removeObject(forKey: Key.scheduledDeletionAt)
    }
}
