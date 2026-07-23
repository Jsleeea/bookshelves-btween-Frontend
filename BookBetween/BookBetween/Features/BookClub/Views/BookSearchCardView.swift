import SwiftUI

struct BookSearchCardView: View {
	let book: Book

	var body: some View {
		ZStack(alignment: .center) {
			Color.gray50

			VStack(alignment: .leading, spacing: 0) {
				BookCoverImage(book: book, placeholderImageName: "book_cover_02")
					.aspectRatio(29.0/44.0, contentMode: .fit)
					.frame(height: 145)
                    .clipShape(RoundedRectangle(cornerRadius: 9.14))
                    .padding(.top, 5)
                    .padding(.bottom, 12)

                Text(book.title)
                    .head3Style
                    .lineLimit(1)
                    .foregroundStyle(Color.gray800)
                    .padding(.bottom, 5.7)

                Text(book.publisher.map { "\(book.author) | \($0)" } ?? book.author)
                    .body1RegularStyle
                    .lineLimit(1)
                    .foregroundStyle(Color.gray500)
                    .padding(.bottom, 6.3)
                
			}
		}
        .padding(.horizontal, 8)
        .frame(width: 116, height: 222)
		.clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray200, lineWidth: 0.5)
        }
        .padding(.leading, 27)
	}
}

#Preview {
	ScrollView(.horizontal, showsIndicators: false) {
		HStack(spacing: 16) {
			BookSearchCardView(book: Book(
				id: 1,
				title: "혼모노",
				author: "성해나",
				publisher: "창비",
				kdcName: "한국소설"
			))
			BookSearchCardView(book: Book(
				id: 2,
				title: "빛은 얼마나 깊이 스미는가",
				author: "김초엽",
				publisher: "창비",
				kdcName: "SF소설"
			))
			BookSearchCardView(book: Book(
				id: 3,
				title: "프로젝트 헤일메리",
				author: "앤디 위어",
				publisher: "알에이치코리아",
				kdcName: "SF소설"
			))
		}
	}
}
