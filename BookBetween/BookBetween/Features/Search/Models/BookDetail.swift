//
//  BookDetail.swift
//  BookBetween
//

import Foundation

struct BookDetail {
    let book: Book
    let memberBook: UserBookRecord?

    var record: UserBookRecord {
        memberBook ?? UserBookRecord(book: book, progress: 0)
    }
}

struct RecentSearchItem {
    let keyword: String
    let searchedAt: Date
}
