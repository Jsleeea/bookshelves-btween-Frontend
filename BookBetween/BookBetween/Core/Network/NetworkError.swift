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
        case .decoding(let error):
            #if DEBUG
            return "서버 응답을 처리하지 못했습니다.\n\(Self.diagnosis(of: error))"
            #else
            return "서버 응답을 처리하지 못했습니다."
            #endif
        case .server(_, _, let message):
            return message
        case .emptyResult:
            return "서버 응답에 필요한 데이터가 없습니다."
        }
    }

    /// 디코딩이 어느 필드에서 왜 실패했는지 한 줄로 요약합니다.
    /// 콘솔을 보지 않고도 원인을 알 수 있도록 DEBUG 빌드에서만 노출합니다.
    private static func diagnosis(of error: DecodingError) -> String {
        switch error {
        case let .keyNotFound(key, context):
            return "키 없음: \(path(context, appending: key.stringValue))"
        case let .valueNotFound(type, context):
            return "값이 null: \(path(context)) (\(type) 기대)"
        case let .typeMismatch(type, context):
            return "타입 불일치: \(path(context)) (\(type) 기대)"
        case let .dataCorrupted(context):
            return "형식 오류: \(path(context)) \(context.debugDescription)"
        @unknown default:
            return "\(error)"
        }
    }

    private static func path(
        _ context: DecodingError.Context,
        appending key: String? = nil
    ) -> String {
        let components = context.codingPath.map(\.stringValue) + [key].compactMap { $0 }
        return components.isEmpty ? "(최상위)" : components.joined(separator: ".")
    }
}
