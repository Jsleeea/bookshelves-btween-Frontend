import SwiftUI

struct BookMeetingCreateView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var meetingDate = Date()
	@State private var timerMinutes = 5
	@State private var maxParticipants = 3
	@State private var showingMeetingDatePicker = false
	@State private var showingMeetingTimePicker = false
	@State private var showingTimerPicker = false
	@State private var showingParticipantsPicker = false
	@State private var isCreating = false
	@State private var creationError: String?
    @State private var showSuccessModal = false

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

	private static let apiDateFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = "yyyy-MM-dd"
		f.locale = Locale(identifier: "en_US_POSIX")
		return f
	}()

	private static let apiTimeFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = "HH:mm"
		f.locale = Locale(identifier: "en_US_POSIX")
		return f
	}()

	private static let participantCapacity = 6
	private static let participantsFloor = 3
	private static let timerMinuteOptions = Array(stride(from: 5, through: 60, by: 5))

	let book: Book
	private let service: (any MeetingServiceProtocol)?
    private let onMeetingCreated: (() -> Void)?

	init(book: Book, service: (any MeetingServiceProtocol)? = nil, onMeetingCreated: (() -> Void)? = nil) {
		self.book = book
		self.service = service
        self.onMeetingCreated = onMeetingCreated
	}

	var body: some View {
        ZStack {
            Color.beige100.ignoresSafeArea()
            leafDecoration
            VStack(spacing: 0) {
                navigationHeader
                    .padding(.top, 8)
                    .padding(.bottom, 7)
                subtitleHeader
                    .padding(.bottom, 6)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 0) {
                        bookHeaderSection
                            .padding(.bottom, 24)
                        descriptionText
                            .padding(.bottom, 52)
                        meetingInfoSection
                            .padding(.bottom, 40)
                        noticeSection
                            .padding(.bottom, 24)
                        BottomActionButton(title: isCreating ? "생성 중..." : "+ 모임 생성하기") {
                            guard !isCreating, let isbn = book.isbn else { return }
                            Task {
                                isCreating = true
                                defer { isCreating = false }
                                do {
                                    _ = try await service?.createMeeting(
                                        isbn: isbn,
                                        startDate: Self.apiDateFormatter.string(from: meetingDate),
                                        startTime: Self.apiTimeFormatter.string(from: meetingDate),
                                        maxParticipants: maxParticipants,
                                        duration: timerMinutes
                                    )
                                    showSuccessModal = true
                                } catch {
                                    creationError = error.localizedDescription
                                }
                            }
                        }
                        .padding(.bottom, 42)
                        .disabled(isCreating || book.isbn == nil)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .enableSwipeBack()
		.overlay {
            if showSuccessModal {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    SuccessModalView(title: "모임을 생성했습니다") {
                        dismiss()
                        onMeetingCreated?()
                    }
                }
            }
        }
		.toolbar(.hidden, for: .navigationBar)
		.hideTabBar()
		.alert("모임 생성 실패", isPresented: Binding(
			get: { creationError != nil },
			set: { if !$0 { creationError = nil } }
		)) {
			Button("확인", role: .cancel) { creationError = nil }
		} message: {
			Text(creationError ?? "")
		}
	}

    // MARK: - Decoration
    
    private var leafDecoration: some View {
        Image(.leaf1)
            .resizable()
            .scaledToFit()
            .frame(width: 133)
            .offset(x: 137, y: -320)
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
			BookCoverImage(book: book, placeholderImageName: "book_cover_mock")
				.aspectRatio(29.0/44.0, contentMode: .fit)
				.frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray200, lineWidth: 0.5)
                }

			VStack(alignment: .leading, spacing: 4) {
				Text(book.title)
					.head1Style
                    .foregroundStyle(Color.gray800)
                    .padding(.bottom, 4)

				Text(book.publisher.map { "\(book.author) | \($0)" } ?? book.author)
					.body2RegularStyle
					.foregroundStyle(Color.gray500)

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
        .padding(.top, 6)
        .padding(.horizontal, 28.5)
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
					withAnimation(.easeInOut(duration: 0.3)) {
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
					withAnimation(.easeInOut(duration: 0.3)) {
						showingMeetingDatePicker = false
						showingTimerPicker = false
						showingParticipantsPicker = false
						showingMeetingTimePicker.toggle()
					}
				},
				picker: {
					HStack(spacing: 0) {
						Picker("시", selection: hourBinding) {
							ForEach(0...23, id: \.self) { h in
								Text(String(format: "%02d시", h)).tag(h)
							}
						}
						.pickerStyle(.wheel)
						.frame(maxWidth: .infinity)

						Picker("분", selection: minuteBinding) {
							ForEach(0...59, id: \.self) { m in
								Text(String(format: "%02d분", m)).tag(m)
							}
						}
						.pickerStyle(.wheel)
						.frame(maxWidth: .infinity)
					}
					.frame(height: 150)
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
					withAnimation(.easeInOut(duration: 0.3)) {
						showingMeetingDatePicker = false
						showingMeetingTimePicker = false
						showingParticipantsPicker = false
						showingTimerPicker.toggle()
					}
				},
				picker: {
					Picker("타이머 시간", selection: $timerMinutes) {
						ForEach(Self.timerMinuteOptions, id: \.self) { m in
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
				value: "\(maxParticipants)/\(Self.participantCapacity)",
				isExpanded: showingParticipantsPicker,
				onTap: {
					withAnimation(.easeInOut(duration: 0.3)) {
						showingMeetingDatePicker = false
						showingMeetingTimePicker = false
						showingTimerPicker = false
						showingParticipantsPicker.toggle()
					}
				},
				picker: {
					Picker("참여자", selection: $maxParticipants) {
						ForEach(Self.participantsFloor...Self.participantCapacity, id: \.self) { count in
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
                .stroke(Color.gray200, lineWidth: 0.5)
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
					.transition(.opacity)
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

	private var hourBinding: Binding<Int> {
		Binding(
			get: { Calendar.current.component(.hour, from: meetingDate) },
			set: { newHour in
				var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: meetingDate)
				comps.hour = newHour
				meetingDate = Calendar.current.date(from: comps) ?? meetingDate
			}
		)
	}

	private var minuteBinding: Binding<Int> {
		Binding(
			get: { Calendar.current.component(.minute, from: meetingDate) },
			set: { newMinute in
				var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: meetingDate)
				comps.minute = newMinute
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
					.foregroundStyle(Color.green700)
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
        .padding(.horizontal, 29)
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
