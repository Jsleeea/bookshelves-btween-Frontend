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
    private let bookService: any BookServiceProtocol
    private let meetingService: (any MeetingServiceProtocol)?

    init() {
        _viewModel = State(
            initialValue: HomeViewModel(service: HomeService.stubbed())
        )
        self.bookService = BookService.stubbed()
        self.meetingService = nil
    }
    
    init(
        viewModel: HomeViewModel,
        bookService: any BookServiceProtocol,
        meetingService: (any MeetingServiceProtocol)?
    ) {
        _viewModel = State(initialValue: viewModel)
        self.bookService = bookService
        self.meetingService = meetingService
    }
    
    var body: some View {
        ScrollView(showsIndicators: false){
            if let home = viewModel.home {
                VStack{
                    UserTitleView(home: home)
                    if let recommendedBook = home.recommendedBook {
                        RecommendationSection(
                            recommendedBook: recommendedBook
                        )
                    }
                    if let recentBook = home.recentBook {
                        RecentBookSection(record: recentBook.record)
                    }
                    if !home.meetings.isEmpty {
                        RecruitingMeetingSection(home: home)
                    }
                }
                .padding(.horizontal, 19)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
        }
        .refreshable {
            await viewModel.fetchHome()
        }
        .overlay {
            if viewModel.isLoading && viewModel.home == nil {
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
    private func RecommendationSection(
        recommendedBook: HomeRecommendedBook
    ) -> some View {
        let recommendation = recommendedBook.book
        let authorAndCategory = recommendation.kdcName.flatMap { kdcName in
            kdcName.isEmpty ? nil : "\(recommendation.author) | \(kdcName)"
        } ?? recommendation.author

        return NavigationLink(value: HomeRoute.bookDetail(recommendation)) {
            ZStack{
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
                            Text("오늘의 추천 도서")
                                .body2SemiBoldStyle
                                .foregroundStyle(.green900)
                        }
                        Text(recommendedBook.recommendationMessage)
                            .caption1RegularStyle
                            .foregroundStyle(.gray600)
                            .lineLimit(1)
                            .padding(.top, 3)
                        Spacer()
                        Text(recommendation.title)
                            .pointText3Style
                            .foregroundStyle(.gray800)
                        Text(authorAndCategory)
                            .caption2RegularStyle
                            .foregroundStyle(.gray600)
                            .padding(.top, 4)

                        Spacer()
                    }
                    .padding(.vertical, 18)
                    .padding(.leading, 19)
                    .padding(.top, 21)

                    Spacer()

                    BookCoverImage(
                        book: recommendation,
                        placeholderImageName: "book_cover_mock"
                    )
                    .frame(width: 87, height: 132)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(
                        color: Color(red: 0.33, green: 0.32, blue: 0.31).opacity(0.2),
                        radius: 1.5,
                        x: 0,
                        y: 3
                    )
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.trailing, 27)
                    .padding(.bottom, 14)
                }
                .background(alignment: .bottomTrailing) {
                    Image("home_recommendation_leaf")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 58)
                        .allowsHitTesting(false)
                        .offset(x: -100, y: -30)
                }
            }
        }
        .buttonStyle(.plain)
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
            NavigationLink(value: HomeRoute.recentBookDetail(record)) {
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
                    MeetingCardView(
                        meeting: meeting,
                        service: meetingService
                    )
                }
            }
        }
        .padding(.top, 20)
    }
}

#Preview {
    HomeView()
}
