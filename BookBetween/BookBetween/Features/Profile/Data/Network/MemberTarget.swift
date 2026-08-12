//
//  MemberTarget.swift
//  BookBetween
//

import Foundation
import Alamofire
import Moya

// MARK: - 회원 API 대상

nonisolated struct MemberTarget: TargetType, AuthorizationRequirement {
    // MARK: - API 엔드포인트

    enum Endpoint {
        case me
        case updateMe(MemberProfileUpdateRequestDTO)
        case withdraw
    }

    let baseURL: URL
    let endpoint: Endpoint

    // MARK: - 요청 경로

    var path: String {
        switch endpoint {
        case .me, .updateMe, .withdraw:
            return "/api/v1/members/me"
        }
    }

    // MARK: - HTTP 메서드

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

    // MARK: - 요청 작업

    var task: Moya.Task {
        switch endpoint {
        case .me, .withdraw:
            return .requestPlain
        case .updateMe(let request):
            return .requestJSONEncodable(request)
        }
    }

    // MARK: - 인증 필요 여부

    var requiresAuthorization: Bool {
        true
    }

    // MARK: - 요청 헤더

    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
