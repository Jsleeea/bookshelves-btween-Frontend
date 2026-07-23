//
//  MyLibraryBookCardView.swift
//  BookBetween
//

import SwiftUI

struct MyLibraryBookCardView: View {
	let record: UserBookRecord

	var body: some View {
		ZStack {
			HStack(alignment: .top, spacing: 16) {
				bookCover
                    .padding(.leading, 17.95)

				VStack(alignment: .leading, spacing: 0) {
					bookInfo

					if let quote = record.memo, !quote.isEmpty {
						Text("\u{201C}\(quote)\u{201D}")
							.caption2RegularStyle
							.foregroundStyle(Color.gray500)
							.lineLimit(2)
					}
				}

				Spacer()
			}

			VStack {
				HStack {
					Spacer()
					moreButtonLabel
				}
				Spacer()
			}

			NavigationLink {
				BookRecordDetailView(record: record)
			} label: {
				Color.clear
					.contentShape(Rectangle())
			}
		}
        .padding(.vertical, 15)
        .padding(.trailing, 18.05)
		.background(.white)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.overlay {
			RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray300, lineWidth: 0.5)
		}
        .padding(.horizontal, 19)
        .frame(height: 160)
	}

	// MARK: - Views

	private var bookCover: some View {
		BookCoverImage(book: record.book, placeholderImageName: "book_cover_meeting_1")
			.aspectRatio(29.0/44.0, contentMode: .fit)
			.frame(height: 130)
			.clipped()
			.shadow(color: .black.opacity(0.1), radius: 4, x: -4, y: 4)
	}

	private var bookInfo: some View {
		VStack(alignment: .leading, spacing: 2) {
			Text(record.book.title)
				.body1SemiBoldStyle
                .foregroundStyle(Color.gray800)
				.lineLimit(1)
                .padding(.top, 6.5)

			Text(record.book.author)
				.caption1RegularStyle
				.foregroundStyle(Color.gray500)

			HStack(spacing: 4) {
                Image(.iconStar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 14, height: 14)
                    .clipped()
				Text(ratingText)
					.caption1RegularStyle
					.foregroundStyle(Color.green600)
			}
            .padding(.bottom, 2)

			BookProgressView(progress: record.progress)
                .padding(.bottom, 4)
		}
	}

	private var moreButtonLabel: some View {
		HStack(spacing: 4) {
			Text("더보기")
				.caption1RegularStyle
			Image("icon_chevron_right_gray")
				.resizable()
				.scaledToFill()
				.frame(width: 6, height: 12)
				.clipped()
		}
		.foregroundStyle(Color.gray500)
	}

	// MARK: - Helpers

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
