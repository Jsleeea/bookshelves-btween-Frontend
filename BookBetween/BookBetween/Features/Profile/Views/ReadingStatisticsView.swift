//
//  ReadingStatisticsView.swift
//  BookBetween
//

import Charts
import SwiftUI

// MARK: - 독서 통계 상세 화면

@MainActor
struct ReadingStatisticsView: View {
    // MARK: - 속성

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ReadingStatisticsViewModel

    let joinedAt: Date

    // MARK: - 초기화

    init(
        viewModel: ReadingStatisticsViewModel,
        joinedAt: Date
    ) {
        _viewModel = State(initialValue: viewModel)
        self.joinedAt = joinedAt
    }

    init(
        joinedAt: Date = Calendar.current.date(
            from: DateComponents(year: 2026, month: 3, day: 1)
        ) ?? .now
    ) {
        _viewModel = State(
            initialValue: ReadingStatisticsViewModel(
                bookService: BookService.stubbed()
            )
        )
        self.joinedAt = joinedAt
    }

    // MARK: - 화면 구성

    var body: some View {
        ZStack {
            Color.beige100
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ReadingStatisticsHeaderView {
                        dismiss()
                    }

                    ReadingStatisticsSummaryView(
                        readBookCount: viewModel.completedBookCount,
                        reviewCount: viewModel.reviewCount,
                        averageRating: viewModel.averageRating
                    )
                    .padding(.horizontal, 20)

                    ReadingRatioCardView(joinedAt: joinedAt)
                        .padding(.horizontal, 30)
                        .padding(.top, 16)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .task {
            guard viewModel.statistics == nil else {
                return
            }

            await viewModel.fetchStatistics()
        }
    }
}

// MARK: - 상단 헤더

private struct ReadingStatisticsHeaderView: View {
    // MARK: - 속성

    let onBack: () -> Void

    // MARK: - 화면 구성

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image("icon_arrow_left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }

            Text("독서통계")
                .head1Style
                .foregroundStyle(Color.gray800)

            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 32)
    }
}

// MARK: - 읽은 책 비율 카드

private struct ReadingRatioCardView: View {
    // MARK: - 속성

    let joinedAt: Date

    @State private var selectedMonth: Date
    @State private var isInfoVisible = false

    // MARK: - 목업 데이터

    private let readingRatios = [
        ReadingRatio(
            name: "한국 문학",
            bookCount: 14,
            percentage: 60,
            color: Color(red: 0.24, green: 0.4, blue: 0.29),
            gradientEndColor: Color(red: 0.64, green: 0.77, blue: 0.69),
            labelColor: .white
        ),
        ReadingRatio(
            name: "영미문학",
            bookCount: 6,
            percentage: 25,
            color: Color(red: 0.69, green: 0.79, blue: 0.7),
            gradientEndColor: Color(red: 0.85, green: 0.9, blue: 0.86),
            labelColor: Color.gray700
        ),
        ReadingRatio(
            name: "심리학",
            bookCount: 4,
            percentage: 15,
            color: Color(red: 0.87, green: 0.92, blue: 0.99),
            gradientEndColor: Color(red: 0.96, green: 0.98, blue: 1),
            labelColor: Color.gray700
        ),
        ReadingRatio(
            name: "기타",
            bookCount: 0,
            percentage: 0,
            color: Color(red: 0.93, green: 0.92, blue: 0.9),
            gradientEndColor: Color(red: 0.98, green: 0.97, blue: 0.96),
            labelColor: Color.gray700
        )
    ]

    // MARK: - 초기화

    init(joinedAt: Date) {
        self.joinedAt = joinedAt
        _selectedMonth = State(
            initialValue: Calendar.current.dateInterval(
                of: .month,
                for: joinedAt
            )?.start ?? joinedAt
        )
    }

    // MARK: - 화면 구성

    var body: some View {
        VStack(spacing: 0) {
            cardHeader
                .zIndex(1)

            donutChart
                .padding(.top, 19)

            Spacer()
                .frame(height: 57)

            legendList
        }
        .padding(.horizontal, 16.5)
        .padding(.top, 15)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.75, green: 0.85, blue: 0.78), location: 0.03),
                    Gradient.Stop(color: .white, location: 0.57),
                    Gradient.Stop(color: Color(red: 0.75, green: 0.85, blue: 0.78), location: 0.95)
                ],
                startPoint: UnitPoint(x: 1.05, y: 1.03),
                endPoint: UnitPoint(x: 0.05, y: 0)
            )
            .opacity(0.25)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray200, lineWidth: 0.5)
        }
    }

    // MARK: - 카드 헤더

    private var cardHeader: some View {
        HStack {
            HStack(spacing: 4) {
                Text("읽은 책 비율")
                    .body2SemiBoldStyle
                    .foregroundStyle(Color.gray800)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isInfoVisible.toggle()
                    }
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color.gray500)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("읽은 책 비율 안내")
            }
            .overlay(alignment: .topLeading) {
                if isInfoVisible {
                    infoMessage
                        .offset(y: 32)
                        .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .topLeading)))
                }
            }

            Spacer()

            monthSelectionMenu
        }
    }

    // MARK: - 안내 문구

    private var infoMessage: some View {
        Text("내가 읽은 책을 장르별로\n분류한 비율이에요")
            .body2RegularStyle
            .foregroundStyle(Color.gray600)
            .fixedSize(horizontal: false, vertical: true)
            .padding(12)
            .frame(width: 156, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray300, lineWidth: 0.5)
            }
            .shadow(color: Color(red: 0.17, green: 0.16, blue: 0.16).opacity(0.1), radius: 2, x: 0, y: 4)

    }

    // MARK: - 연월 선택 메뉴

    private var monthSelectionMenu: some View {
        Menu {
            ForEach(selectableYears, id: \.self) { year in
                Menu {
                    ForEach(months(in: year), id: \.self) { date in
                        Button {
                            selectedMonth = date
                        } label: {
                            let month = Calendar.current.component(.month, from: date)

                            if Calendar.current.isDate(date, equalTo: selectedMonth, toGranularity: .month) {
                                Label("\(month)월", systemImage: "checkmark")
                            } else {
                                Text("\(month)월")
                            }
                        }
                    }
                } label: {
                    Text(verbatim: "\(year)년")
                }
            }
        } label: {
            HStack(spacing: 5) {
                Text(selectedMonthTitle)
                    .caption2RegularStyle

                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .medium))
            }
            .foregroundStyle(Color.gray800)
            .padding(.horizontal, 6.72)
            .frame(height: 20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.gray200, lineWidth: 0.5)
            }
        }
    }

    // MARK: - 도넛 차트

    private var donutChart: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 200, height: 200)
                .shadow(
                    color: .black.opacity(0.25),
                    radius: 2,
                    x: 0,
                    y: 4
                )

            Chart(readingRatios.filter { $0.percentage > 0 }) { ratio in
                SectorMark(
                    angle: .value("비율", ratio.percentage),
                    innerRadius: .ratio(0.4),
                    angularInset: 0
                )
                .foregroundStyle(ratio.gradient)
                .annotation(position: .overlay) {
                    Text("\(ratio.percentage)%")
                        .caption1SemiBoldStyle
                        .foregroundStyle(ratio.labelColor)
                }
            }
            .chartLegend(.hidden)
            .frame(width: 190, height: 190)
        }
        .frame(width: 200, height: 200)
        .overlay {
            VStack(spacing: 3) {
                Text("총")
                    .caption2RegularStyle
                    .foregroundStyle(Color.gray700)

                Text("\(readingRatios.reduce(0) { $0 + $1.bookCount })개")
                    .caption1SemiBoldStyle
                    .foregroundStyle(Color.green600)
            }
        }
    }

    // MARK: - 장르별 범례

    private var legendList: some View {
        VStack(spacing: 0) {
            ForEach(Array(readingRatios.enumerated()), id: \.element.id) { index, ratio in
                if index < readingRatios.count {
                    Divider()
                        .overlay(Color.gray200)
                }

                HStack(spacing: 4) {
                    Circle()
                        .fill(ratio.color)
                        .frame(width: 15, height: 15)
                        .padding(.trailing, 8)

                    Text(ratio.name)
                        .body2RegularStyle
                        .foregroundStyle(Color.gray600)

                    Spacer()

                    Text("\(ratio.bookCount)권")
                        .body2SemiBoldStyle
                        .foregroundStyle(Color.gray600)
                    Text("(\(ratio.percentage)%)")
                        .body2RegularStyle
                        .foregroundStyle(Color.gray600)
                }
                .padding(.top, 8)
                .padding(.bottom, 11)
            }
        }
    }

    // MARK: - 날짜 계산

    private var selectedMonthTitle: String {
        let components = Calendar.current.dateComponents(
            [.year, .month],
            from: selectedMonth
        )

        return "\(components.year ?? 0)년 \(components.month ?? 0)월"
    }

    private var selectableMonths: [Date] {
        let calendar = Calendar.current
        let joinedMonth = calendar.dateInterval(of: .month, for: joinedAt)?.start ?? joinedAt
        let currentMonth = calendar.dateInterval(of: .month, for: .now)?.start ?? .now
        let firstMonth = min(joinedMonth, currentMonth)

        var months: [Date] = []
        var month = firstMonth

        while month <= currentMonth {
            months.append(month)

            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: month) else {
                break
            }

            month = nextMonth
        }

        return months
    }

    private var selectableYears: [Int] {
        Array(
            Set(
                selectableMonths.compactMap {
                    Calendar.current.dateComponents([.year], from: $0).year
                }
            )
        )
        .sorted()
    }

    private func months(in year: Int) -> [Date] {
        selectableMonths.filter {
            Calendar.current.component(.year, from: $0) == year
        }
    }
}

// MARK: - 독서 장르 비율 모델

private struct ReadingRatio: Identifiable {
    let name: String
    let bookCount: Int
    let percentage: Int
    let color: Color
    let gradientEndColor: Color
    let labelColor: Color

    var id: String { name }

    var gradient: LinearGradient {
        LinearGradient(
            stops: [
                Gradient.Stop(color: color, location: 0),
                Gradient.Stop(color: gradientEndColor, location: 1)
            ],
            startPoint: UnitPoint(x: 0.97, y: 0.1),
            endPoint: UnitPoint(x: 0.35, y: 1.1)
        )
    }
}

#Preview {
    NavigationStack {
        ReadingStatisticsView()
    }
}
