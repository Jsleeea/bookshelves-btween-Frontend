//
//  APIResponseDTO.swift
//  BookBetween
//
//  Created by 이준성 on 7/19/26.
//

import Foundation

struct APIResponseDTO<Payload: Decodable>: Decodable { // 서버 응답 공통 format
    let isSuccess: Bool
    let code: String
    let message: String
    let result: Payload?
}
