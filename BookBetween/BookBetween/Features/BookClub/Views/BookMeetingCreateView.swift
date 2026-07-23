import SwiftUI

struct BookMeetingCreateView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var meetingDate = Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 30, hour: 10)) ?? Date()
	@State private var timerMinutes = 30
	@State private var maxParticipants = 3
	@State private var showingMeetingDatePicker = false
	@State private var showingMeetingTimePicker = false
	@State private var showingTimerPicker = false
	@State private var showingParticipantsPicker = false

	private static let dateOnlyFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = "MM/dd"
		return f
	}()

	private static let timeOnlyFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = "HH:mm"
		return f
	}()

	let book: Book

	var body: some View {
        ZStack {
            Color.beige100.ignoresSafeArea()
            leafDecoration
            VStack(spacing: 0) {
                navigationHeader
                    .padding(.top, 1)
                    .padding(.bottom, 7)
                subtitleHeader
                    .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 0) {
                        bookHeaderSection
                            .padding(.bottom, 24)
                        descriptionText
                            .padding(.bottom, 52)
                        meetingInfoSection
                            .padding(.bottom, 32)
                        noticeSection
                            .padding(.horizontal, 29)
                            .padding(.bottom, 12)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .safeAreaInset(edge: .bottom) {
                    bottomButton("+ 모임 생성하기") {}
                        .padding(.horizontal, 29)
                }
            }
        }
		.toolbar(.hidden, for: .navigationBar)
		.hideTabBar()
	}

    // MARK: - Decoration
    
    private var leafDecoration: some View {
        Image(.leaf1)
            .resizable()
            .scaledToFit()
            .frame(width: 123)
            .opacity(0.55)
            .rotationEffect(.degrees(-5))
            .offset(x: 137, y: -300)
            .allowsHitTesting(false)
    }
    
	// MARK: - Navigation Header

	private var navigationHeader: some View {
		HStack(spacing: 12) {
			Button { dismiss() } label: {
				Image(.iconChevronRightGray2)
					.resizable()
					.scaledToFill()
					.frame(width: 20, height: 20)
					.clipped()
                    .foregroundStyle(Color.gray600)
			}
			Text("독서 모임")
				.head2Style
                .foregroundStyle(Color.gray900)
			Spacer()
		}
		.padding(.horizontal, 30)
	}

	private var subtitleHeader: some View {
		HStack {
			Text("같이 읽을 책과 모임 정보를 설정해주세요")
				.caption1RegularStyle
				.foregroundStyle(Color.gray500)
			Spacer()
		}
		.padding(.horizontal, 62)
	}
    
	// MARK: - Book Header

	private var bookHeaderSection: some View {
		HStack(alignment: .center, spacing: 16) {
			BookCoverImage(book: book, placeholderImageName: "book_cover_01")
				.aspectRatio(29.0/44.0, contentMode: .fit)
				.frame(height: 160)
				.clipped()
				.shadow(color: .black.opacity(0.1), radius: 4, x: -4, y: 4)

			VStack(alignment: .leading, spacing: 0) {
				Text(book.title)
					.head1Style
                    .foregroundStyle(Color.gray800)
                    .padding(.bottom, 8)

				Text(book.publisher.map { "\(book.author) | \($0)" } ?? book.author)
					.caption1RegularStyle
					.foregroundStyle(Color.gray500)
                    .padding(.bottom, 4)

				if let kdcName = book.kdcName {
					Text(kdcName)
						.caption1SemiBoldStyle
						.foregroundStyle(Color.white)
						.padding(.horizontal, 10)
						.padding(.vertical, 2)
						.background(Color.green600)
						.clipShape(Capsule())
				}
			}
            
            Spacer()
		}
        .padding(.horizontal, 29.5)
	}

	@ViewBuilder
	private var descriptionText: some View {
		if let description = book.description, !description.isEmpty {
			Text(description)
				.caption1RegularStyle
				.foregroundStyle(Color.gray600)
                .padding(.horizontal, 29.5)
                .lineLimit(4)
		}
	}

	// MARK: - Meeting Info

	private var meetingInfoSection: some View {
		VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 4.5) {
				Image("icon_calendar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .clipped()
                    .foregroundStyle(Color.gray600)
				Text("모임정보")
					.head2Style
                    .foregroundStyle(Color.gray600)
			}
			.padding(.horizontal, 6)

			meetingInfoCard
                .padding(.horizontal, 4)
		}
        .padding(.horizontal, 19)
	}

	private var meetingInfoCard: some View {
		VStack(spacing: 0) {
			infoRow(
				icon: { Image("icon_calendar") },
				label: "모임 날짜",
				value: Self.dateOnlyFormatter.string(from: meetingDate),
				isExpanded: showingMeetingDatePicker,
				onTap: {
					withAnimation(.easeInOut(duration: 0.2)) {
						showingMeetingTimePicker = false
						showingTimerPicker = false
						showingParticipantsPicker = false
						showingMeetingDatePicker.toggle()
					}
				},
				picker: {
					HStack(spacing: 0) {
						Picker("월", selection: monthBinding) {
							ForEach(1...12, id: \.self) { m in
								Text("\(m)월").tag(m)
							}
						}
						.pickerStyle(.wheel)
						.frame(maxWidth: .infinity)

						Picker("일", selection: dayBinding) {
							ForEach(1...daysInSelectedMonth, id: \.self) { d in
								Text("\(d)일").tag(d)
							}
						}
						.pickerStyle(.wheel)
						.frame(maxWidth: .infinity)
					}
					.frame(height: 150)
					.padding(.horizontal, 8)
				}
			)
            .padding(.top, 9)
            .padding(.bottom,6)

            Divider()
                .overlay(Color.gray300)

			infoRow(
				icon: { Image("icon_calendar")},
				label: "모임 시간",
				value: Self.timeOnlyFormatter.string(from: meetingDate),
				isExpanded: showingMeetingTimePicker,
				onTap: {
					withAnimation(.easeInOut(duration: 0.2)) {
						showingMeetingDatePicker = false
						showingTimerPicker = false
						showingParticipantsPicker = false
						showingMeetingTimePicker.toggle()
					}
				},
				picker: {
					DatePicker("", selection: $meetingDate, displayedComponents: [.hourAndMinute])
						.datePickerStyle(.wheel)
						.labelsHidden()
						.environment(\.locale, Locale(identifier: "en_GB"))
						.frame(height: 150)
						.clipped()
						.padding(.horizontal, 8)
				}
			)
            .padding(.top, 24)
            .padding(.bottom, 6)

            Divider()
                .overlay(Color.gray300)

			infoRow(
				icon: { Image("icon_clock").resizable().scaledToFill().frame(width: 14, height: 14).clipped() },
				label: "타이머 시간",
				value: "\(timerMinutes)분",
				isExpanded: showingTimerPicker,
				onTap: {
					withAnimation(.easeInOut(duration: 0.2)) {
						showingMeetingDatePicker = false
						showingMeetingTimePicker = false
						showingParticipantsPicker = false
						showingTimerPicker.toggle()
					}
				},
				picker: {
					Picker("타이머 시간", selection: $timerMinutes) {
						ForEach(Array(stride(from: 5, through: 60, by: 5)), id: \.self) { m in
							Text("\(m)분").tag(m)
						}
					}
					.pickerStyle(.wheel)
					.frame(height: 150)
					.padding(.horizontal, 8)
				}
			)
            .padding(.top, 24)
            .padding(.bottom, 6)

            Divider()
                .overlay(Color.gray300)

			infoRow(
				icon: { Image("icon_group") },
				label: "참여자 수",
				value: "\(maxParticipants)/6",
				isExpanded: showingParticipantsPicker,
				onTap: {
					withAnimation(.easeInOut(duration: 0.2)) {
						showingMeetingDatePicker = false
						showingMeetingTimePicker = false
						showingTimerPicker = false
						showingParticipantsPicker.toggle()
					}
				},
				picker: {
					Picker("참여자", selection: $maxParticipants) {
						ForEach(3...6, id: \.self) { count in
							Text("\(count)명").tag(count)
						}
					}
					.pickerStyle(.wheel)
					.frame(height: 150)
					.padding(.horizontal, 8)
				}
			)
            .padding(.top, 24)
            .padding(.bottom, 6)
            
            Divider()
                .overlay(Color.gray300)
            
		}
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray300, lineWidth: 0.5)
        }
	}

	private func infoRow<Icon: View, Picker: View>(
		@ViewBuilder icon: () -> Icon,
		label: String,
		value: String,
		isExpanded: Bool,
		onTap: @escaping () -> Void,
		@ViewBuilder picker: () -> Picker
	) -> some View {
		VStack(spacing: 0) {
			Button(action: onTap) {
				HStack {
					icon()
					Text(label)
						.body2RegularStyle
						.foregroundStyle(Color.gray600)
					Spacer()
					Text(value)
						.body2RegularStyle
						.foregroundStyle(Color.gray600)
					Image(.iconChevronRight)
						.resizable()
						.scaledToFill()
						.frame(width: 6, height: 12)
						.clipped()
						.foregroundStyle(Color.gray600)
				}
                .padding(.horizontal, 8)
			}
			.buttonStyle(.plain)

			if isExpanded {
				picker()
					.transition(.opacity.combined(with: .move(edge: .top)))
			}
		}
	}

	// MARK: - Date Picker Helpers

	private var monthBinding: Binding<Int> {
		Binding(
			get: { Calendar.current.component(.month, from: meetingDate) },
			set: { newMonth in
				var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: meetingDate)
				comps.month = newMonth
				comps.day = min(comps.day ?? 1, maxDays(year: comps.year ?? 2026, month: newMonth))
				meetingDate = Calendar.current.date(from: comps) ?? meetingDate
			}
		)
	}

	private var dayBinding: Binding<Int> {
		Binding(
			get: { Calendar.current.component(.day, from: meetingDate) },
			set: { newDay in
				var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: meetingDate)
				comps.day = newDay
				meetingDate = Calendar.current.date(from: comps) ?? meetingDate
			}
		)
	}

	private var daysInSelectedMonth: Int {
		maxDays(
			year: Calendar.current.component(.year, from: meetingDate),
			month: Calendar.current.component(.month, from: meetingDate)
		)
	}

	private func maxDays(year: Int, month: Int) -> Int {
		let comps = DateComponents(year: year, month: month)
		guard let date = Calendar.current.date(from: comps) else { return 30 }
		return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 30
	}

	// MARK: - Notice

	private var noticeSection: some View {
		HStack(alignment: .center, spacing: 12) {
			Image(.leaf3)
				.resizable()
				.scaledToFill()
				.frame(width: 20, height: 20)
				.clipped()
			VStack(alignment: .leading, spacing: 4) {
				Text("모임은 타이머 설정 시간 만료 후  자동으로 폭파돼요.")
					.caption2SemiBoldStyle
					.foregroundStyle(Color.green600)
				Text("편안하고 안전한 대화를 위해 최소인원 3명 이상이 필요해요.")
					.caption2RegularStyle
					.foregroundStyle(Color.gray500)
			}
		}
        .frame(maxWidth: .infinity)
		.padding(.top, 12)
        .padding(.bottom, 9)
		.background(Color.green50.opacity(0.5))
		.clipShape(RoundedRectangle(cornerRadius: 8))
	}
}

#Preview {
	NavigationStack {
		BookMeetingCreateView(
			book: Book(
				id: 1,
				title: "혼모노",
				author: "성해나",
				publisher: "창비",
				description: "성해나 작가의 단편 소설집 『혼모노』는 진짜와 가짜, 믿음에 대한 날카로운 질문을 던지는 작품입니다.\n표제작 『혼모노』는 신발을 읽고 20대 애기 무당에게 자리를 빼앗긴 베테랑 무당이 진정한 자신의 정체성을 찾아가는 과정을 그립니다.",
				kdcName: "한국소설"
			)
		)
	}
}
