//
//  HomeView.swift
//  BookBetween
//
//  Created by 이준성 on 6/25/26.
//

import SwiftUI

@MainActor
struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init() {
        _viewModel = State(
            initialValue: HomeViewModel(service: HomeService.stubbed())
        )
    }
    
    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false){
            if let home = viewModel.home {
                VStack{
                    UserTitleView(home: home)
                    RecommendationSection(home: home)
                    if let recentBook = home.recentBook {
                        RecentBookSection(record: recentBook.record)
                    }
                    RecruitingMeetingSection(home: home)
                }
                .padding(.horizontal, 19)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.fetchHome()
        }
        .alert(
            "홈 화면을 불러오지 못했습니다.",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("확인", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private func UserTitleView(home: Home) -> some View {
        HStack{
            Text("\(home.member.nickname)의 책장")
                .pointText1Style
            Spacer()
            NavigationLink(value: HomeRoute.notificationInbox) {
                Image("icon_bell")
                    .resizable()
                    .frame(width: 24, height: 26)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 10)
    }
    
    // MARK: - 오늘의 AI 추천도서
    private func RecommendationSection(home: Home) -> some View {
        let recommendedBook = home.recommendedBook
        let recommendation = recommendedBook.book
        let authorAndCategory = recommendation.kdcName.flatMap { kdcName in
            kdcName.isEmpty ? nil : "\(recommendation.author) | \(kdcName)"
        } ?? recommendation.author

        return ZStack{
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 4)

            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(hex: "DCEBE1"), location: 0.0),
                            Gradient.Stop(color: Color(hex: "EEF8F0"), location: 0.45),
                            Gradient.Stop(color: .white, location: 1.0)
                        ],
                        startPoint: UnitPoint(x: 0.68, y: 0.0),
                        endPoint: UnitPoint(x: 0.26, y: 1.0)
                    )
                )
                .opacity(0.7)

            HStack{
                VStack(alignment: .leading, spacing: 0){
                    HStack{
                        Image("icon_sparkles")
                        Text("오늘의 AI 추천도서")
                            .body1SemiBoldStyle
                            .foregroundStyle(.green900)
                    }
                    Text(recommendedBook.recommendationMessage)
                        .caption1RegularStyle
                        .foregroundStyle(.gray600)
                        .lineLimit(1)
                        .padding(.top, 3)
                    Spacer()
                    Text(recommendation.title)
                        .pointText4Style
                        .foregroundStyle(.gray800)
                    Text(authorAndCategory)
                        .caption2RegularStyle
                        .foregroundStyle(.gray600)
                        .padding(.top, 4)

                    Spacer()
                    NavigationLink {
                        BookRecordDetailView(
                            book: recommendation,
                            isSaveable: recommendation.isbn != nil
                        )
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
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 18)
                .padding(.leading, 19)
                Spacer()
                
                BookCoverImage(book: recommendation,
                               placeholderImageName: "book_cover_recommend"
                )
                .frame(width:87, height: 132)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.trailing, 27)
                .padding(.bottom, 14)
            }
        }
        .frame(height: 160)
        .padding(.top, 12)
    }

    private func RecentBookSection(record: UserBookRecord) -> some View {
        VStack{
            HStack{
                Text("최근 본 책")
                    .body1SemiBoldStyle
                Spacer()
            }
            NavigationLink {
                BookRecordDetailView(record: record)
            } label: {
                RecentBookCardView(record: record)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 20)
    }

    private func RecruitingMeetingSection(home: Home) -> some View {
        VStack(alignment: .leading){
                Text("모집 중인 모임")
                    .body1SemiBoldStyle
                VStack{
                ForEach(home.meetings, id: \.id) { meeting in
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
