//
//  KakaoLoginService.swift
//  BookBetween
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser

// MARK: - 카카오 로그인 서비스 규약

@MainActor
protocol KakaoLoginServiceProtocol {
    func login() async throws -> String
}

@MainActor
final class KakaoLoginService: KakaoLoginServiceProtocol {
    // MARK: - 로그인 요청

    func login() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let completion: (OAuthToken?, Error?) -> Void = { token, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let accessToken = token?.accessToken,
                      !accessToken.isEmpty else {
                    continuation.resume(
                        throwing: KakaoLoginServiceError.missingAccessToken
                    )
                    return
                }

                continuation.resume(returning: accessToken)
            }

            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(completion: completion)
            } else {
                UserApi.shared.loginWithKakaoAccount(completion: completion)
            }
        }
    }
}

// MARK: - 카카오 로그인 오류

nonisolated enum KakaoLoginServiceError: LocalizedError {
    case missingAccessToken

    var errorDescription: String? {
        switch self {
        case .missingAccessToken:
            return "카카오 로그인 토큰을 확인할 수 없습니다. 다시 시도해주세요."
        }
    }
}
