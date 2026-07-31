//
//  AuthTarget.swift
//  BookBetween
//

import Foundation
import Alamofire
import Moya

nonisolated struct AuthTarget: TargetType, AuthorizationRequirement {
    enum Endpoint {
        case socialLogin(SocialLoginRequestDTO)
        case logout
        case reissue(TokenReissueRequestDTO)
        case restore(AccountRestoreRequestDTO)
    }

    let baseURL: URL
    let endpoint: Endpoint

    var path: String {
        switch endpoint {
        case .socialLogin:
            return "/api/v1/auth/social-login"
        case .logout:
            return "/api/v1/auth/logout"
        case .reissue:
            return "/api/v1/auth/reissue"
        case .restore:
            return "/api/v1/auth/restore"
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .socialLogin, .logout, .reissue, .restore:
            return .post
        }
    }

    var task: Moya.Task {
        switch endpoint {
        case .socialLogin(let request):
            return .requestJSONEncodable(request)
        case .logout:
            return .requestPlain
        case .reissue(let request):
            return .requestJSONEncodable(request)
        case .restore(let request):
            return .requestJSONEncodable(request)
        }
    }

    var requiresAuthorization: Bool {
        switch endpoint {
        case .socialLogin, .reissue, .restore:
            return false
        case .logout:
            return true
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
