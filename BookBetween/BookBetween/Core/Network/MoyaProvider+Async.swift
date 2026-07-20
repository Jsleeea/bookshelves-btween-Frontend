//
//  MoyaProvider+Async.swift
//  BookBetween
//
//  Created by 이준성 on 7/19/26.
//


import Moya

extension MoyaProvider { // 최신 비동기 문법 지원
    func requestAsync(_ target: Target) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            request(target) { result in
                continuation.resume(with: result)
            }
        }
    }
}
