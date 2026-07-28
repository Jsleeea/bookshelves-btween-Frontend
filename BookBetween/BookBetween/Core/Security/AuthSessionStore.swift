//
//  AuthSessionStore.swift
//  BookBetween
//

import Foundation

nonisolated protocol AuthSessionStoreProtocol {
    func saveMemberStatus(_ status: MemberStatus)
    func memberStatus() -> MemberStatus?
    func clear()
}

nonisolated final class AuthSessionStore: AuthSessionStoreProtocol {
    private enum Key {
        static let memberStatus = "auth.memberStatus"
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

    func clear() {
        userDefaults.removeObject(forKey: Key.memberStatus)
    }
}
