//
//  UserBookRecord.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import Foundation

struct UserBookRecord: Hashable {
    let id: Int?
    let book: Book
    var progress: Int
    var rating: Double?
    var memo: String?

    init(
        id: Int? = nil,
        book: Book,
        progress: Int,
        rating: Double? = nil,
        memo: String? = nil
    ) {
        self.id = id
        self.book = book
        self.progress = progress
        self.rating = rating
        self.memo = memo
    }
}
