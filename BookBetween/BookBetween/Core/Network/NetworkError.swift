//
//  NetworkError.swift
//  BookBetween
//
//  Created by 이준성 on 7/19/26.
//

import Foundation
import Moya

enum NetworkError: LocalizedError {
    case transport(MoyaError)
    case decoding(DecodingError)
    case server(statusCode: Int, code: String, message: String)
    case emptyResult

    var errorDescription: String? {
        switch self {
        case .transport:
            return "네트워크 연결을 확인해주세요."
        case .decoding:
            return "서버 응답을 처리하지 못했습니다."
        case .server(_, _, let message):
            return message
        case .emptyResult:
            return "서버 응답에 필요한 데이터가 없습니다."
        }
    }
}
