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
        case withdraw
    }

    let baseURL: URL
    let endpoint: Endpoint

    var path: String {
        switch endpoint {
        case .me, .updateMe, .withdraw:
            return "/api/v1/members/me"
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .me:
            return .get
        case .updateMe:
            return .patch
        case .withdraw:
            return .delete
        }
    }

    var task: Moya.Task {
        switch endpoint {
        case .me, .withdraw:
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
