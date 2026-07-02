//
//  Book.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import Foundation

struct Book {
    let id: String
    let title: String
    let author: String
    let description: String?
    let thumbnailURL: String? //책 표지 이미지 주소
    let thumbnailImageName: String? // MockUpdata 용으로 추가. (임시)
}
