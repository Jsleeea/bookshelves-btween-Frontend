//
//  Response+API.swift
//  BookBetween
//
//  Created by 이준성 on 7/19/26.
//

import Foundation
import Moya

extension Response { // 데이터 가공 + 검증
    func decodePayload<Payload: Decodable>(
        _ type: Payload.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> Payload {
        let metadata: APIResponseMetadataDTO

        do {
            metadata = try decoder.decode(
                APIResponseMetadataDTO.self,
                from: data
            )
        } catch let error as DecodingError {
            #if DEBUG
            print("""
            [Decoding Error] 공통 응답 format 아님
            URL: \(request?.url?.absoluteString ?? "확인 불가")
            HTTP: \(statusCode)
            error: \(error)
            body: \(String(data: data, encoding: .utf8) ?? "확인 불가")
            """)
            #endif

            // 공통 응답 format이 아닌 바디(5xx 기본 에러 응답, 게이트웨이 HTML 등)는
            // 디코딩 실패가 아니라 서버 오류로 알려야 원인이 드러납니다.
            guard (200..<300).contains(statusCode) else {
                throw NetworkError.server(
                    statusCode: statusCode,
                    code: "HTTP\(statusCode)",
                    message: "서버 오류가 발생했습니다. (\(statusCode))"
                )
            }

            throw NetworkError.decoding(error)
        }

        guard (200..<300).contains(statusCode), metadata.isSuccess else {
            #if DEBUG
            print("""
            [API Error]
            URL: \(request?.url?.absoluteString ?? "확인 불가")
            HTTP: \(statusCode)
            code: \(metadata.code)
            message: \(metadata.message)
            """)
            #endif

            throw NetworkError.server(
                statusCode: statusCode,
                code: metadata.code,
                message: metadata.message
            )
        }

        let response: APIResponseDTO<Payload>

        do {
            response = try decoder.decode(
                APIResponseDTO<Payload>.self,
                from: data
            )
        } catch let error as DecodingError {
            #if DEBUG
            print("""
            [Decoding Error]
            URL: \(request?.url?.absoluteString ?? "확인 불가")
            payload: \(Payload.self)
            error: \(error)
            body: \(String(data: data, encoding: .utf8) ?? "확인 불가")
            """)
            #endif

            throw NetworkError.decoding(error)
        }

        guard let result = response.result else {
            throw NetworkError.emptyResult
        }

        return result
    }

    func validateAPIResponse(
        decoder: JSONDecoder = JSONDecoder()
    ) throws {
        let response: APIResponseDTO<EmptyAPIResultDTO>

        do {
            response = try decoder.decode(
                APIResponseDTO<EmptyAPIResultDTO>.self,
                from: data
            )
        } catch let error as DecodingError {
            throw NetworkError.decoding(error)
        }

        guard (200..<300).contains(statusCode), response.isSuccess else {
            throw NetworkError.server(
                statusCode: statusCode,
                code: response.code,
                message: response.message
            )
        }
    }
}

private struct EmptyAPIResultDTO: Decodable {}
