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
