//
//  MemberTarget.swift
//  BookBetween
//

import Foundation
import Alamofire
import Moya

nonisolated struct MemberTarget: TargetType, AuthorizationRequirement {
    enum Endpoint {
        case me
        case updateMe(MemberProfileUpdateRequestDTO)
    }

    let baseURL: URL
    let endpoint: Endpoint

    var path: String {
        switch endpoint {
        case .me, .updateMe:
            return "/api/v1/members/me"
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .me:
            return .get
        case .updateMe:
            return .patch
        }
    }

    var task: Moya.Task {
        switch endpoint {
        case .me:
            return .requestPlain
        case .updateMe(let request):
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
