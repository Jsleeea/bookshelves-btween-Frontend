//
//  BookSearchItem.swift
//  BookBetween
//

import Foundation

struct BookSearchItem: Hashable {
    let listID: UUID
    let book: Book
    let isSaveable: Bool

    init(
        listID: UUID = UUID(),
        book: Book,
        isSaveable: Bool
    ) {
        self.listID = listID
        self.book = book
        self.isSaveable = isSaveable && book.isbn != nil
    }
}

struct BookSearchPage {
    let books: [BookSearchItem]
    let page: Int
    let size: Int
    let hasNext: Bool
}
