//
//  AuthTarget.swift
//  BookBetween
//

import Foundation
import Alamofire
import Moya

nonisolated struct AuthTarget: TargetType {
    enum Endpoint {
        case socialLogin(SocialLoginRequestDTO)
    }

    let baseURL: URL
    let endpoint: Endpoint

    var path: String {
        switch endpoint {
        case .socialLogin:
            return "/api/v1/auth/social-login"
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .socialLogin:
            return .post
        }
    }

    var task: Moya.Task {
        switch endpoint {
        case .socialLogin(let request):
            return .requestJSONEncodable(request)
        }
    }

    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    var sampleData: Data {
        AuthStubScenario.pendingOnboarding.response.data
    }
}
