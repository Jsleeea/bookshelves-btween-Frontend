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
    }

    let baseURL: URL
    let endpoint: Endpoint

    var path: String {
        switch endpoint {
        case .complete:
            return "/api/v1/members/me/onboarding"
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .complete:
            return .post
        }
    }

    var task: Moya.Task {
        switch endpoint {
        case .complete(let request):
            return .requestJSONEncodable(request)
        }
    }

    var requiresAuthorization: Bool {
        true
    }

    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
