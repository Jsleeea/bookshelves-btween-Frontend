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
        HStack{
            Image(record.book.thumbnailImageName ?? "book_cover_recent")
            VStack{
                HStack{
                    VStack(alignment: .leading){
                        Text(record.book.title)
                            .body1SemiBoldStyle
                            .foregroundStyle(.gray800)

                        Text(record.book.author)
                            .caption1RegularStyle
                            .foregroundStyle(.gray500)
                    }
                    .padding(.top, 7)
                    
                    Spacer()
                    
                    HStack{
                        Image("icon_star")
                        Text(ratingText)
                            .caption1RegularStyle
                            .foregroundStyle(.green600)
                    }
                    .padding(.trailing, 16)
                }
                Spacer()
                ProgressView(value: record.progress)
                    .tint(.green600)
            }
        }
        .padding(10)
        .frame(height: 129)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray300, lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.1), radius: 1, x: 2, y: 2)
    }

    private var ratingText: String {
        guard let rating = record.rating else { return "-" }
        return String(format: "%.1f", rating)
    }
}

#Preview {
    RecentBookCardView(
        record: UserBookRecord(
            book: Book(
                id: "recent-1",
                title: "아무 희미한 빛으로도",
                author: "최은영",
                description: nil,
                thumbnailURL: nil,
                thumbnailImageName: "book_cover_recent"
            ),
            progress: 0.75,
            oneLineReview: nil,
            rating: 4.5
        )
    )
}
