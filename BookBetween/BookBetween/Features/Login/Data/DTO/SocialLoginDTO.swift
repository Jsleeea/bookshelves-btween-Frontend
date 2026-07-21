//
//  SocialLoginDTO.swift
//  BookBetween
//

import Foundation

nonisolated enum SocialProvider: String, Encodable {
    case kakao = "KAKAO"
}

nonisolated enum MemberStatus: String, Decodable {
    case pendingOnboarding = "PENDING_ONBOARDING"
    case active = "ACTIVE"
    case suspended = "SUSPENDED"
    case withdrawn = "WITHDRAWN"
    case anonymized = "ANONYMIZED"
}

nonisolated struct SocialLoginRequestDTO: Encodable {
    let provider: SocialProvider
    let providerToken: String
}

nonisolated struct SocialLoginResultDTO: Decodable {
    let accessToken: String?
    let refreshToken: String?
    let accessTokenExpiresIn: Int?
    let refreshTokenExpiresIn: Int?
    let restoreToken: String?
    let restoreTokenExpiresIn: Int?
    let memberStatus: MemberStatus
    let scheduledDeletionAt: String?
}
