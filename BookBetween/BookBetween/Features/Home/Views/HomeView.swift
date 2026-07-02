//
//  HomeView.swift
//  BookBetween
//
//  Created by 이준성 on 6/25/26.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack{
                UserTitleView
                RecommendationSection
                RecentBookSection
                RecruitingMeetingSection
            }
            .padding(.horizontal, 19)
        }
    }
    
    private var UserTitleView: some View {
        HStack{
            Text("\(viewModel.home.user.nickname)의 책장")
                .head1Style
            Spacer()
        }
        .padding(.leading, 10)
    }

    // MARK: - 오늘의 AI 추천도서
    private var RecommendationSection: some View {
        let recommendation = viewModel.home.dailyRecommendation

        return ZStack{
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "FFE4C2"),
                            Color(hex: "CCE1D2")
                        ],
                        startPoint:. top,
                        endPoint:. bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.gray300), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.1), radius: 2, x: -4, y: 4)
            HStack{
                VStack(alignment: .leading){
                    HStack{
                        Image("icon_sparkles")
                        Text("오늘의 AI 추천도서")
                            .body1SemiBoldStyle
                            .foregroundStyle(.green900)
                    }
                    Text(recommendation.description)
                        .caption1RegularStyle
                        .foregroundStyle(.gray600)
                    Spacer()
                    Text(recommendation.book.title)
                        .head3Style
                        .foregroundStyle(.gray800)
                    Text(recommendation.book.author)
                        .caption2RegularStyle
                        .foregroundStyle(.gray600)

                    Spacer()
                    Button{
                        //책읽기 화면으로 이동
                    } label: {
                        HStack{
                            Text("책 읽으러 가기")
                                .caption1RegularStyle
                            Image("icon_chevron_right_white")
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                        .background(.green800)
                        .clipShape(Capsule())
                    }
                }
                .padding(.vertical, 18)
                .padding(.leading, 19)
                Spacer()
                
                Image(recommendation.book.thumbnailImageName ?? "book_cover_recommend")
                    .resizable()
                    .scaledToFit()
                    .frame(width:86, height: 146)
                    .padding(.trailing, 26.5)
            }
        }
        .frame(height: 155)
        .padding(.top, 12)
    }

    private var RecentBookSection: some View {
        VStack{
            HStack{
                Text("최근 본 책")
                    .body1SemiBoldStyle
                Spacer()
                Button {
                    
                }label: {
                    HStack{
                        Text("전체보기")
                            .body2RegularStyle
                            .foregroundStyle(.gray500)
                        Image("icon_chevron_right_gray")
                    }
                }
            }
            ForEach(viewModel.home.recentBooks, id: \.book.id) { record in
                RecentBookCardView(record: record)
            }
        }
        .padding(.top, 20)

    }

    private var RecruitingMeetingSection: some View {
        VStack(alignment: .leading){
                Text("모집 중인 모임")
                    .body1SemiBoldStyle
                VStack{
                ForEach(viewModel.home.recruitingMeetings, id: \.id) { meeting in
                    MeetingCardView(meeting: meeting)
                }
            }
        }
        .padding(.horizontal, 9)
        .padding(.top, 20)

    }

    
}

#Preview {
    HomeView()
}
