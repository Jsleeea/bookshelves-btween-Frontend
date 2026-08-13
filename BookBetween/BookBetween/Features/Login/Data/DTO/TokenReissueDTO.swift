//
//  TokenReissueDTO.swift
//  BookBetween
//

import Foundation

// MARK: - 토큰 재발급 요청

nonisolated struct TokenReissueRequestDTO: Encodable {
    let refreshToken: String
}

// MARK: - 토큰 재발급 응답

nonisolated struct TokenReissueResultDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresIn: Int
    let refreshTokenExpiresIn: Int
}
