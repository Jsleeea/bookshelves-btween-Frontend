//
//  Book.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import Foundation

struct Book: Decodable, Hashable {
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.isbn == rhs.isbn && lhs.id == rhs.id && lhs.title == rhs.title
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(isbn)
        hasher.combine(id)
        hasher.combine(title)
    }

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

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        isbn = try c.decodeIfPresent(String.self, forKey: .isbn)
        title = try c.decode(String.self, forKey: .title)
        author = try c.decodeIfPresent(String.self, forKey: .author) ?? ""
        publisher = try c.decodeIfPresent(String.self, forKey: .publisher)
        publishedDate = try c.decodeIfPresent(String.self, forKey: .publishedDate)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        coverImageUrl = try c.decodeIfPresent(String.self, forKey: .coverImageUrl)
        kdcCode = try c.decodeIfPresent(String.self, forKey: .kdcCode)
        kdcName = try c.decodeIfPresent(String.self, forKey: .kdcName)
    }

    private enum CodingKeys: String, CodingKey {
        case id, isbn, title, author, publisher, publishedDate, description, coverImageUrl, kdcCode, kdcName
    }
}
