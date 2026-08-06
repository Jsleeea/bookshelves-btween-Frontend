import SwiftUI
import Kingfisher

struct BookCoverImage: View {
    let coverImageUrl: String?
    let placeholderImageName: String

    @State private var loadFailed = false

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
        if let coverURL, !loadFailed {
            KFImage(coverURL)
                .placeholder { placeholderImage }
                .onFailure { _ in loadFailed = true }
                .resizable()
                .fade(duration: 0.2)
                .cancelOnDisappear(true)
                .scaledToFill()
                .onChange(of: coverImageUrl) { _, _ in loadFailed = false }
        } else {
            fallbackImage
        }
    }

    private var placeholderImage: some View {
        Image(placeholderImageName)
            .resizable()
            .scaledToFill()
    }

    private var fallbackImage: some View {
        Image("book_cover_mock")
            .resizable()
            .scaledToFill()
    }
}


