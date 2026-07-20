//
//  NetworkConfiguration.swift
//  BookBetween
//
//  Created by 이준성 on 7/19/26.
//

import Foundation

struct NetworkConfiguration { // 네트워크 설정
    let baseURL: URL
    let accessToken: () -> String?

    init(
        baseURL: URL,
        accessToken: @escaping () -> String? = { nil }
    ) {
        self.baseURL = baseURL
        self.accessToken = accessToken
    }
}
