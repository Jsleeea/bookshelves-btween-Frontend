//
//  Book.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import Foundation

struct Book: Decodable {
    let id: Int?
    let isbn: String?
    let title: String
    let author: String
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let coverImageUrl: String?
    let kdcCode: String?
    let kdcName: String?

    init(
        id: Int? = nil,
        isbn: String? = nil,
        title: String,
        author: String,
        publisher: String? = nil,
        publishedDate: String? = nil,
        description: String? = nil,
        coverImageUrl: String? = nil,
        kdcCode: String? = nil,
        kdcName: String? = nil
    ) {
        self.id = id
        self.isbn = isbn
        self.title = title
        self.author = author
        self.publisher = publisher
        self.publishedDate = publishedDate
        self.description = description
        self.coverImageUrl = coverImageUrl
        self.kdcCode = kdcCode
        self.kdcName = kdcName
    }
}
