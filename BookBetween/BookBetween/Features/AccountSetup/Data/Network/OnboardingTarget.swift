//
//  OnboardingTarget.swift
//  BookBetween
//

import Foundation
import Alamofire
import Moya

nonisolated struct OnboardingTarget: TargetType, AuthorizationRequirement {
    enum Endpoint {
        case complete(OnboardingRequestDTO)
        case terms
    }

    let baseURL: URL
    let endpoint: Endpoint

    var path: String {
        switch endpoint {
        case .complete:
            return "/api/v1/members/me/onboarding"
        case .terms:
            return "/api/v1/onboarding/terms"
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .complete:
            return .post
        case .terms:
            return .get
        }
    }

    var task: Moya.Task {
        switch endpoint {
        case .complete(let request):
            return .requestJSONEncodable(request)
        case .terms:
            return .requestPlain
        }
    }

    var requiresAuthorization: Bool {
        switch endpoint {
        case .complete:
            return true
        case .terms:
            return false
        }
    }

    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
