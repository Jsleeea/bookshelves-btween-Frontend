//
//  ProfileView.swift
//  BookBetween
//
//

import SwiftUI

@MainActor
struct ProfileView: View {
    // MARK: - 속성

    @State private var viewModel: ProfileViewModel
    @State private var statisticsViewModel: ReadingStatisticsViewModel
    @State private var isReadingStatisticsPresented = false
    private let onLogout: () async throws -> Void
    private let onWithdraw: () async throws -> Void

    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    init(
        onLogout: @escaping () async throws -> Void = {},
        onWithdraw: @escaping () async throws -> Void = {}
    ) {
        _viewModel = State(initialValue: ProfileViewModel())
        _statisticsViewModel = State(
            initialValue: ReadingStatisticsViewModel(
                bookService: BookService.stubbed()
            )
        )
        self.onLogout = onLogout
        self.onWithdraw = onWithdraw
    }

    init(
        viewModel: ProfileViewModel,
        statisticsViewModel: ReadingStatisticsViewModel,
        onLogout: @escaping () async throws -> Void,
        onWithdraw: @escaping () async throws -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        _statisticsViewModel = State(initialValue: statisticsViewModel)
        self.onLogout = onLogout
        self.onWithdraw = onWithdraw
    }

    private var displayedMonthTitle: String {
        viewModel.displayedMonth.formatted(
            .dateTime
                .locale(Locale(identifier: "ko_KR"))
                .year()
                .month(.wide)
        )
    }

    private var joinedAt: Date {
        Calendar.current.date(
            byAdding: .day,
            value: -max((viewModel.profile?.joinedDays ?? 1) - 1, 0),
            to: .now
        ) ?? .now
    }

    // MARK: - 화면 구성
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text("마이페이지")
                    .head2Style
                    .foregroundStyle(Color.gray900)
                    .padding(.bottom, 16)

                profileCard
                    .padding(.bottom, 50)

                ReadingStatisticsSummaryView(
                    readBookCount: statisticsViewModel.completedBookCount,
                    reviewCount: statisticsViewModel.reviewCount,
                    averageRating: statisticsViewModel.averageRating
                ) {
                    isReadingStatisticsPresented = true
                }
                    .padding(.bottom, 16)

                Text("독서 캘린더")
                    .head2Style
                    .foregroundStyle(Color.gray900)
                    .padding(.bottom, 18)

                readingCalendar
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
        .background(Color.beige100)
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            if viewModel.isLoading
                || viewModel.isCalendarLoading
                || statisticsViewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            async let profileRequest: Void = viewModel.fetchMyProfile()
            async let statisticsRequest: Void = statisticsViewModel.fetchStatistics()
            async let calendarRequest: Void = viewModel.fetchReadingCalendar()

            _ = await (
                profileRequest,
                statisticsRequest,
                calendarRequest
            )
        }
        .navigationDestination(isPresented: $isReadingStatisticsPresented) {
            ReadingStatisticsView(
                viewModel: statisticsViewModel,
                joinedAt: joinedAt
            )
        }
        .alert(
            "마이페이지 정보를 불러오지 못했습니다.",
            isPresented: Binding(
                get: {
                    viewModel.errorMessage != nil
                        || viewModel.calendarErrorMessage != nil
                        || statisticsViewModel.errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                        viewModel.calendarErrorMessage = nil
                        statisticsViewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("확인", role: .cancel) {
                viewModel.errorMessage = nil
                viewModel.calendarErrorMessage = nil
                statisticsViewModel.errorMessage = nil
            }
        } message: {
            Text(
                viewModel.errorMessage
                    ?? viewModel.calendarErrorMessage
                    ?? statisticsViewModel.errorMessage
                    ?? ""
            )
        }
    }

    private var profileCard: some View {
        HStack(spacing: 23) {
            profileImage

            VStack(alignment: .leading, spacing: 0) {
                Text("\(viewModel.profile?.nickname ?? "책 먹는 여우")님")
                    .head3Style
                    .foregroundStyle(Color.gray800)
                    .padding(.bottom, 5)

                Text("가입 \(viewModel.profile?.joinedDays ?? 124)일")
                    .body2RegularStyle
                    .foregroundStyle(Color.gray600)
                    .padding(.bottom, 8)

                editProfileButton
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 130)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray200, lineWidth: 0.5)
        }
    }

    private var profileImage: some View {
        let animalImageName = NicknameGenerator.animalImageName(
            for: viewModel.profile?.nicknameAnimal
                ?? GeneratedNickname.placeholder.animal
        )

        return ZStack {
            Circle()
                .fill(profileBackgroundGradient)

            Image(animalImageName)
                .resizable()
                .scaledToFit()
        }
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(Color.white, lineWidth: 2.5)
        }
        // 그림자 추후에 값 수정해야함
        .shadow(color: Color.black.opacity(0.1), radius: 2, y: 2)
    }

    private var profileBackgroundGradient: LinearGradient {
        let endColor: Color

        switch ProfileBackgroundColorCode(
            rawValue: viewModel.profile?.profileBackgroundColor ?? ""
        ) {
        case .purple:
            endColor = Color(red: 0.47, green: 0.47, blue: 0.75)
        case .blue:
            endColor = Color(red: 0.51, green: 0.73, blue: 0.96)
        case .green:
            endColor = Color(red: 0.6, green: 0.76, blue: 0.65)
        case .red:
            endColor = Color(red: 1, green: 0.46, blue: 0.3)
        case .yellow:
            endColor = Color(red: 0.94, green: 0.79, blue: 0.37)
        case .brown, .none:
            endColor = Color(red: 0.69, green: 0.5, blue: 0.28)
        }

        return LinearGradient(
            stops: [
                Gradient.Stop(
                    color: Color.white.opacity(0.4),
                    location: 0
                ),
                Gradient.Stop(color: endColor, location: 1)
            ],
            startPoint: UnitPoint(x: -0.17, y: 0.17),
            endPoint: UnitPoint(x: 1.17, y: 0.83)
        )
    }

    private var editProfileButton: some View {
        NavigationLink {
            ProfileEditView(
                profile: viewModel.profile,
                onSave: { request in
                    try await viewModel.updateMyProfile(
                        request: request
                    )
                },
                onLogout: onLogout,
                onWithdraw: onWithdraw
            )
        } label: {
            HStack(spacing: 4) {
                Image("icon_pencil")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)

                Text("정보 수정하기")
                    .caption1RegularStyle
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.green700)
            .cornerRadius(12)
        }
    }

    private var readingCalendar: some View {
        VStack(spacing: 0) {
            calendarHeader
            weekdayHeader
            calendarGrid
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray200, lineWidth: 0.5)
        }
    }

    private var calendarHeader: some View {
        HStack {
            Button {
                viewModel.moveToPreviousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.gray500)
            }

            Spacer()

            Text(displayedMonthTitle)
                .head2Style
                .foregroundStyle(Color.gray800)

            Spacer()

            Button {
                viewModel.moveToNextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.gray500)
            }
        }
        .padding(.horizontal, 32)
        .frame(height: 76)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .caption1SemiBoldStyle
                    .foregroundStyle(Color.gray500)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: 31)
        .background(Color.gray100)
    }

    private var calendarGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

        return LazyVGrid(columns: columns, spacing: 0) {
            ForEach(viewModel.calendarDays) { calendarDay in
                calendarCell(for: calendarDay)
            }
        }
    }

    private func calendarCell(for calendarDay: CalendarDay) -> some View {
        let readingDay = viewModel.readingCalendarDay(
            for: calendarDay.date
        )

        return ZStack(alignment: .topLeading) {
            Text("\(calendarDay.day)")
                .caption2RegularStyle
                .foregroundStyle(
                    calendarDay.isCurrentMonth
                        ? Color.gray800
                        : Color.gray300
                )
                .padding(.top, 5)
                .padding(.leading, 8)

            if calendarDay.isCurrentMonth,
               let readingDay {
                BookCoverImage(
                    coverImageUrl: readingDay.coverImageUrl,
                    placeholderImageName: "book_cover_mock"
                )
                .frame(width: 45, height: 55)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 21)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(height: 80)
        .clipped()
        .overlay {
            Rectangle()
                .stroke(Color.gray300, lineWidth: 0.5)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
