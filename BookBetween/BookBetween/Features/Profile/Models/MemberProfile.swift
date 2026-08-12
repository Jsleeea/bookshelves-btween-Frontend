//
//  MemberProfile.swift
//  BookBetween
//

import Foundation

// MARK: - 회원 프로필 모델

nonisolated struct MemberProfile: Equatable {
    let memberId: Int
    let nickname: String
    let nicknameNoun: String
    let nicknameModifier: String
    let nicknameAnimal: String
    let profileBackgroundColor: String
    let joinedDays: Int
    let categories: [MemberCategory]
}

// MARK: - 회원 장르 모델

nonisolated struct MemberCategory: Equatable, Identifiable {
    let categoryId: Int
    let name: String

    var id: Int {
        categoryId
    }
}
