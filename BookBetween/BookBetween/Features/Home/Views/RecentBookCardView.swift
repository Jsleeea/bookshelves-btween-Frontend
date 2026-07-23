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
            BookCoverImage(book: record.book, placeholderImageName: "book_cover_recent")
                .frame(width: 72.8, height: 109.52)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading){
                HStack{
                    VStack(alignment: .leading, spacing: 0){
                        Text(record.book.title)
                            .body1SemiBoldStyle
                            .foregroundStyle(.gray800)

                        Text(record.book.author)
                            .caption1RegularStyle
                            .foregroundStyle(.gray500)
                            .padding(.top,4)
                    }
                    .padding(.top, 7)// 기본으로 10 들어감 - total: 17
                    
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
                BookProgressView(progress: record.progress)
                    .tint(.green600)
                    .frame(width: 246)
                    .padding(.bottom, 19)
            }
            .padding(.leading, 13.24)
        }
        .padding(10)
        .frame(height: 129)
        .frame(maxWidth: .infinity)
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
