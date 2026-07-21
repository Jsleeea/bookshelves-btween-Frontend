//
//  AuthStubResponse.swift
//  BookBetween
//

import Foundation

nonisolated struct AuthStubResponse {
    let statusCode: Int
    let data: Data
}

nonisolated enum AuthStubScenario {
    case pendingOnboarding
    case active
    case withdrawn
    case unsupportedProvider
    case invalidToken

    var response: AuthStubResponse {
        switch self {
        case .pendingOnboarding:
            return AuthStubResponse(
                statusCode: 200,
                data: Self.makeData(from: Self.pendingOnboardingJSON)
            )

        case .active:
            return AuthStubResponse(
                statusCode: 200,
                data: Self.makeData(from: Self.activeJSON)
            )

        case .withdrawn:
            return AuthStubResponse(
                statusCode: 202,
                data: Self.makeData(from: Self.withdrawnJSON)
            )

        case .unsupportedProvider:
            return AuthStubResponse(
                statusCode: 400,
                data: Self.makeData(from: Self.unsupportedProviderJSON)
            )

        case .invalidToken:
            return AuthStubResponse(
                statusCode: 401,
                data: Self.makeData(from: Self.invalidTokenJSON)
            )
        }
    }

    private static func makeData(from json: String) -> Data {
        guard let data = json.data(using: .utf8) else {
            preconditionFailure("Stub JSON을 UTF-8 데이터로 변환하지 못했습니다.")
        }

        return data
    }

    private static let pendingOnboardingJSON = """
    {
      "isSuccess": true,
      "code": "AUTH200",
      "message": "소셜 로그인에 성공했습니다.",
      "result": {
        "accessToken": "mock-access-token",
        "refreshToken": "mock-refresh-token",
        "accessTokenExpiresIn": 3600,
        "refreshTokenExpiresIn": 1209600,
        "restoreToken": null,
        "restoreTokenExpiresIn": null,
        "memberStatus": "PENDING_ONBOARDING",
        "scheduledDeletionAt": null
      }
    }
    """

    private static let activeJSON = """
    {
      "isSuccess": true,
      "code": "AUTH200",
      "message": "소셜 로그인에 성공했습니다.",
      "result": {
        "accessToken": "mock-access-token",
        "refreshToken": "mock-refresh-token",
        "accessTokenExpiresIn": 3600,
        "refreshTokenExpiresIn": 1209600,
        "restoreToken": null,
        "restoreTokenExpiresIn": null,
        "memberStatus": "ACTIVE",
        "scheduledDeletionAt": null
      }
    }
    """

    private static let withdrawnJSON = """
    {
      "isSuccess": true,
      "code": "AUTH202",
      "message": "탈퇴 대기 중인 계정입니다.",
      "result": {
        "accessToken": null,
        "refreshToken": null,
        "accessTokenExpiresIn": null,
        "refreshTokenExpiresIn": null,
        "restoreToken": "mock-restore-token",
        "restoreTokenExpiresIn": 600,
        "memberStatus": "WITHDRAWN",
        "scheduledDeletionAt": "2026-08-13T14:30:00+09:00"
      }
    }
    """

    private static let unsupportedProviderJSON = """
    {
      "isSuccess": false,
      "code": "AUTH400",
      "message": "지원하지 않는 소셜 로그인 제공자입니다.",
      "result": null
    }
    """

    private static let invalidTokenJSON = """
    {
      "isSuccess": false,
      "code": "AUTH401",
      "message": "유효하지 않은 소셜 토큰입니다.",
      "result": null
    }
    """
}
