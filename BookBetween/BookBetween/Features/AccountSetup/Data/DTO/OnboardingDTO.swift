//
//  OnboardingDTO.swift
//  BookBetween
//

import Foundation

// MARK: - 온보딩 요청 DTO

nonisolated struct OnboardingRequestDTO: Encodable {
    let nicknameNoun: String
    let nicknameModifier: String
    let nicknameAnimal: String
    let profileBackgroundColor: ProfileBackgroundColorCode
    let categoryIds: [Int]
    let agreedTermsIds: [Int]
}

// MARK: - 온보딩 완료 DTO

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

// MARK: - 온보딩 장르 DTO

nonisolated struct OnboardingCategoryDTO: Decodable {
    let id: Int
    let name: String
}

// MARK: - 온보딩 약관 DTO

nonisolated struct OnboardingTermDTO: Decodable {
    let id: Int
    let title: String
    let content: String
    let type: OnboardingTermType
    let version: String
    let isRequired: Bool
}

// MARK: - 온보딩 약관 유형

nonisolated enum OnboardingTermType: String, Decodable {
    case service = "SERVICE"
    case privacy = "PRIVACY"
    case marketing = "MARKETING"
}
