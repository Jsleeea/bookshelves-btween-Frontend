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
        if let coverURL {
            AsyncImage(url: coverURL) { phase in
                switch phase {
                case .empty:
                    Color.clear
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    fallbackImage
                @unknown default:
                    fallbackImage
                }
            }
        } else {
            fallbackImage
        }
    }

    private var fallbackImage: some View {
        Image("book_cover_mock")
            .resizable()
            .scaledToFill()
    }
}


