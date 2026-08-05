//
//  RecentBookCardView.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import SwiftUI

struct RecentBookCardView: View {
    let record: UserBookRecord

    var body: some View {
        HStack(spacing: 0){
            BookCoverImage(book: record.book, placeholderImageName: "book_cover_mock")
                .frame(width: 71, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.gray200, lineWidth: 0.5)
                }

            
            
            VStack(alignment: .leading){
                VStack(alignment: .leading, spacing: 0){
                    Text(record.book.title)
                        .body1SemiBoldStyle
                        .foregroundStyle(.gray800)

                    Text(authorAndPublisherText)
                        .body2RegularStyle
                        .foregroundStyle(.gray500)
                        .padding(.top,4)

                    HStack{
                        Image("icon_star")
                        Text(ratingText)
                            .caption1RegularStyle
                            .foregroundStyle(.green600)
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 7)// 기본으로 10 들어감 - total: 17

                Spacer()
                BookProgressView(progress: record.progress, showsKnob: false)
                    .tint(.green600)
                    .frame(width: 246)
                    .padding(.bottom, 19)
            }
            .padding(.leading, 13.24)
        }
        .padding(.vertical, 10)
        .padding(.trailing, 10)
        .padding(.leading, 13)
        .frame(height: 129)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack(alignment: .trailing){
                Color.white
                Image("leaf_img2")
                    .resizable()
                    .scaledToFit()
                    .frame(width:90.76, height: 85.76)
                    .opacity(0.55)
                    .offset(y: 14)
                    .offset(x: 2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray300, lineWidth: 0.5)
        }
    }

    private var ratingText: String {
        guard let rating = record.rating else { return "-" }
        return String(format: "%.1f", rating)
    }

    private var authorAndPublisherText: String {
        guard
            let publisher = record.book.publisher?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !publisher.isEmpty
        else {
            return record.book.author
        }

        return "\(record.book.author) | \(publisher)"
    }
}

#Preview {
    RecentBookCardView(
        record: UserBookRecord(
            id: 1,
            book: Book(
                id: 1,
                title: "아무 희미한 빛으로도",
                author: "최은영",
                description: nil
            ),
            progress: 75,
            rating: 4.5,
            memo: nil
        )
    )
}
