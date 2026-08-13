import SwiftUI

struct MyLibraryBookCardView: View {
	let record: UserBookRecord

	var body: some View {
		HStack(alignment: .top, spacing: 16) {
			bookCover

			bookInfo
			Spacer()
		}
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
		.background(.white)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.overlay {
			RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray200, lineWidth: 0.5)
		}
        .padding(.horizontal, 19)
        .frame(height: 160)
	}

	// MARK: - Views

	private var bookCover: some View {
		BookCoverImage(book: record.book, placeholderImageName: "book_cover_mock")
			.frame(width: 128.0 * 29.0 / 44.0, height: 128)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray200, lineWidth: 0.5)
            }
	}

	private var bookInfo: some View {
		VStack(alignment: .leading, spacing: 0) {
			Text(record.book.title)
                .body1SemiBoldStyle
                .body1SingleLineHeight
                .foregroundStyle(Color.gray800)
                .padding(.top, 0)
                .lineLimit(1)
                //.lineSpacing(2.5)
                .fixedSize(horizontal: false, vertical: true)

			Text(authorPublisherText)
                .caption1RegularStyle
                .caption1SingleLineHeight
				.foregroundStyle(Color.gray500)
                .padding(.top, 4)
                .lineLimit(1)

			HStack(spacing: 4) {
                Image(.iconStar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 14, height: 14)
                    .clipped()
				Text(ratingText)
                    .caption1RegularStyle
                    .caption1SingleLineHeight
					.foregroundStyle(Color.green600)
                    .padding(.top, 3)
			}

			BookProgressView(progress: record.progress, showsKnob: false)
                .padding(.top, 7)

			if let quote = record.memo, !quote.isEmpty {
				Text("\u{201C}\(quote)\u{201D}")
                    .caption2RegularStyle
                    .caption2SingleLineHeight
                    .padding(.top, 5)
					.foregroundStyle(Color.gray500)
                    .lineLimit(2)
					.lineSpacing(6)
			}
		}
	}

	// MARK: - Helpers

	private var authorPublisherText: String {
		let author = record.book.author.isEmpty ? "저자 미상" : record.book.author
		if let publisher = record.book.publisher, !publisher.isEmpty {
			return "\(author) | \(publisher)"
		}
		return author
	}

	private var ratingText: String {
		guard let r = record.rating else { return "-" }
		return String(format: "%.1f", r)
	}
}

#Preview {
	NavigationStack {
		MyLibraryBookCardView(
			record: UserBookRecord(
				id: 1,
				book: Book(
					id: 1,
					title: "싯다르타",
					author: "헤르만 헤세",
					publisher: "민음사",
					description: "헤르만 헤세의 대표작. 인도를 배경으로 한 청년 싯다르타의 깨달음의 여정을 담은 소설.",
					kdcName: "인도철학"
				),
				progress: 70,
				rating: 4.5,
				memo: "강은 어디에나 있다. 입구이자 출구이며, 시작이자 끝이다."
			)
		)
		.padding()
	}
}
