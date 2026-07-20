//
//  BookCoverImage.swift
//  BookBetween
//

import SwiftUI

struct BookCoverImage: View {
    let coverImageUrl: String?
    let placeholderImageName: String

    private var coverURL: URL? {
        guard let coverImageUrl else { return nil }
        return URL(string: coverImageUrl)
    }

    init(book: Book, placeholderImageName: String) {
        self.coverImageUrl = book.coverImageUrl
        self.placeholderImageName = placeholderImageName
    }

    init(coverImageUrl: String?, placeholderImageName: String) {
        self.coverImageUrl = coverImageUrl
        self.placeholderImageName = placeholderImageName
    }

    var body: some View {
        AsyncImage(url: coverURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                Image(placeholderImageName)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}
