//
//  AuthorizationPlugin.swift
//  BookBetween
//
//  Created by 이준성 on 7/19/26.
//

import Foundation
import Moya

final class AuthorizationPlugin: PluginType { // 로그인 필요한 API 호출때마다 자동 토큰 주입
    private let accessToken: () -> String?

    init(accessToken: @escaping () -> String?) {
        self.accessToken = accessToken
    }

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let token = accessToken(), !token.isEmpty else {
            return request
        }

        var request = request
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
