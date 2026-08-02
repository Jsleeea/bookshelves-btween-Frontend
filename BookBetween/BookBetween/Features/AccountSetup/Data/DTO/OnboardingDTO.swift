//
//  OnboardingDTO.swift
//  BookBetween
//

import Foundation

nonisolated struct OnboardingRequestDTO: Encodable {
    let nicknameNoun: String
    let nicknameModifier: String
    let nicknameAnimal: String
    let profileBackgroundColor: ProfileBackgroundColorCode
    let categoryIds: [Int]
    let agreedTermsIds: [Int]
}

nonisolated struct OnboardingResultDTO: Decodable {
    let id: Int
    let nickname: String
    let nicknameNoun: String
    let nicknameModifier: String
    let nicknameAnimal: String
    let profileBackgroundColor: ProfileBackgroundColorCode
    let provider: String
    let memberStatus: MemberStatus
    let createdAt: String
    let categories: [OnboardingCategoryDTO]
}

nonisolated struct OnboardingCategoryDTO: Decodable {
    let id: Int
    let name: String
}

nonisolated struct OnboardingTermDTO: Decodable {
    let id: Int
    let title: String
    let content: String
    let type: OnboardingTermType
    let version: String
    let isRequired: Bool
}

nonisolated enum OnboardingTermType: String, Decodable {
    case service = "SERVICE"
    case privacy = "PRIVACY"
    case marketing = "MARKETING"
}
