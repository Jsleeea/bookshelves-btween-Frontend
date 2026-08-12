//
//  OnboardingTarget.swift
//  BookBetween
//

import Foundation
import Alamofire
import Moya

// MARK: - 온보딩 API 대상

nonisolated struct OnboardingTarget: TargetType, AuthorizationRequirement {
    // MARK: - API 엔드포인트

    enum Endpoint {
        case complete(OnboardingRequestDTO)
        case terms
    }

    let baseURL: URL
    let endpoint: Endpoint

    // MARK: - 요청 경로

    var path: String {
        switch endpoint {
        case .complete:
            return "/api/v1/members/me/onboarding"
        case .terms:
            return "/api/v1/onboarding/terms"
        }
    }

    // MARK: - HTTP 메서드

    var method: Moya.Method {
        switch endpoint {
        case .complete:
            return .post
        case .terms:
            return .get
        }
    }

    // MARK: - 요청 작업

    var task: Moya.Task {
        switch endpoint {
        case .complete(let request):
            return .requestJSONEncodable(request)
        case .terms:
            return .requestPlain
        }
    }

    // MARK: - 인증 필요 여부

    var requiresAuthorization: Bool {
        switch endpoint {
        case .complete:
            return true
        case .terms:
            return false
        }
    }

    // MARK: - 요청 헤더

    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
