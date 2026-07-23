import SwiftUI

struct BookMeetingResultView: View {
	@Environment(\.dismiss) private var dismiss
	let meeting: BookMeeting

	private var discussion: BookMeetingDiscussion {
		BookMeetingDiscussion(
			meeting: meeting,
			topics: [
				DiscussionTopic(
					id: 1,
					question: "왜 싯다르타는 계속 떠났을까?",
					content: "많은 참여자들은 싯다르타가 깨달음을 얻기 위해서가 아니라, 타인의 답을 자신의 답으로 받아들일 수 없었기 때문에 떠났다고 이야기했다.",
					quote: nil
				),
				DiscussionTopic(
					id: 2,
					question: "가장 인상 깊었던 시기",
					content: "참여자들은 의외로 싯다르타가 성공과 쾌락을 경험하던 시기를 많이 언급했다. 완벽한 실패와 방황과 실패의 시간이 있었기에 마지막 깨달음이 의미 있게 다가왔다는 의견이 많았다.실패와 방황과 실패의 시간이 있었기에 마지막 깨달음이 의미 있게 다가왔다는 의견이 많았다실패와 방황과 실패의 시간이 있었기에 마지막 깨달음이 의미 있게 다가왔다는 의견이 많았다",
					quote: nil
				),
				DiscussionTopic(
					id: 3,
					question: "현재의 나와 연결되는 부분",
					content: "많은 참여자들이 진로 고민, 인간관계, 미래에 대한 불안을 이야기하며 싯다르타의 방황과 자신의 삶을 연결 지었다. 특히 '남들과 비교하여 조급해질 때가 많다.'는 이야기에 여러 참여자가 공감했다.",
					quote: nil
				)
			],
			keywords: []
		)
	}

	var body: some View {
		ZStack {
			gradientBackground
			leafDecoration
			VStack(spacing: 0) {
				navigationHeader
                    .padding(.bottom, 16)

				ScrollView(showsIndicators: false) {
					VStack(alignment: .leading, spacing: 0) {
						bookHeaderSection
                            .padding(.bottom, 16)
						aiSummarySection
                            .padding(.bottom, 8)
						discussionSection
                            
					}
					.padding(.bottom, 60)
				}
				.scrollBounceBehavior(.basedOnSize)
			}
		}
		.toolbar(.hidden, for: .navigationBar)
	}

    // MARK: - Background

    private var gradientBackground: some View {
        Color(hex: "FAF9F6")
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "DCEBE1"), Color(hex: "FAF9F6")],
                            center: .center,
                            startRadius: 0,
                            endRadius: 281
                        )
                    )
                    .frame(width: 562, height: 454)
                    .opacity(0.40)
                    .offset(x: -223, y: -210)
            }
    }

    private var leafDecoration: some View {
        Image(.leaf2)
            .resizable()
            .scaledToFit()
            .frame(width: 170, height: 268)
            .rotationEffect(.degrees(-7))
            .offset(x: 137, y: -250)
            .allowsHitTesting(false)
    }
    
	// MARK: - Navigation Header

	private var navigationHeader: some View {
		HStack(spacing: 8) {
			Button { dismiss() } label: {
				Image(.iconChevronRightGray2)
					.resizable()
					.scaledToFill()
					.frame(width: 20, height: 20)
					.clipped()
			}
			Text("독서 모임")
				.head2Style
                .foregroundStyle(.gray900)
			Spacer()
		}
		.padding(.horizontal, 30)
	}

	// MARK: - Book Header

	private var bookHeaderSection: some View {
        HStack(spacing: 24) {
			BookCoverImage(book: meeting.book, placeholderImageName: "book_cover_01")
				.aspectRatio(29.0/44.0, contentMode: .fit)
				.frame(height: 170)
				.clipped()
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray200, lineWidth: 0.5)
                }

			VStack(alignment: .leading, spacing: 0) {
				Text(meeting.book.title)
					.head3Style
                    .foregroundStyle(Color.gray800)
                    .padding(.top, 2.6)
                    .padding(.bottom, 8)

				Text(meeting.book.publisher.map { "\(meeting.book.author) | \($0)" } ?? meeting.book.author)
					.body2RegularStyle
					.foregroundStyle(Color.gray500)
                
                Spacer()
                
				compactInfoRows
                    .foregroundStyle(Color.gray800)
                    .padding(.bottom, 2.6)
			}
		}
		.padding(.horizontal, 20)
	}

	private var readingPeriodText: String {
		guard let start = meeting.readingStartDate, let end = meeting.readingEndDate else { return "-" }
		return "\(Self.dateFormatter.string(from: start)) - \(Self.dateFormatter.string(from: end))"
	}

	private var compactInfoRows: some View {
		VStack(alignment: .leading, spacing: 8) {
			compactInfoRow(icon: { Image("icon_calendar").resizable().scaledToFill().frame(width: 12, height: 12).clipped()  },
						   text: "독서 기간: \(readingPeriodText)")
			compactInfoRow(icon: { Image("icon_calendar").resizable().scaledToFill().frame(width: 12, height: 12).clipped()  },
						   text: "모임 날짜: \(Self.dateTimeFormatter.string(from: meeting.meetingDate))")
			compactInfoRow(icon: { Image("icon_clock").resizable().scaledToFill().frame(width: 12, height: 12).clipped() },
						   text: "모임 시간: \(meeting.timerMinutes)분")
			compactInfoRow(icon: { Image("icon_group") },
						   text: "참여자: \(meeting.maxParticipants)/6") //수정필요(6 > 모임 신청한 참여자수)
		}
	}

	private func compactInfoRow<Icon: View>(
		@ViewBuilder icon: () -> Icon,
		text: String
	) -> some View {
        HStack(spacing: 4.88) {
			icon()
			Text(text)
				.caption2RegularStyle
				.foregroundStyle(Color.gray800)
		}
	}

	// MARK: - AI Summary

	private var aiSummarySection: some View {
		HStack(alignment: .top, spacing: 12) {
            Image(.star)
				.resizable()
				.scaledToFit()
                .frame(width: 26.8, height: 26.8)
                .padding(6.5)
				.background(
                    LinearGradient(
                        stops: [
                            .init(color: .white, location: 0.8367),
                            .init(color: .white.opacity(0.20), location: 1.5517)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    ),
                    in: Circle()
                )

			VStack(alignment: .leading, spacing: 0) {
				Text("AI 요약")
					.caption1SemiBoldStyle
					.foregroundStyle(Color.green900)

				Text("AI가 오늘 모임의 대화를 분석하여\n핵심 내용을 3가지 주제로 정리했어요.")
					.caption2RegularStyle
					.foregroundStyle(Color.gray700)
			}
            Spacer()
		}
		.padding(12)
		.background(
			LinearGradient(
				stops: [
                    .init(color: Color.green50, location: 0),
                    .init(color: Color.green50.opacity(0.40), location: 1)
				],
				startPoint: .top,
				endPoint: .bottom
			)
		)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.overlay {
			RoundedRectangle(cornerRadius: 12)
				.stroke(
					LinearGradient(
						stops: [
							.init(color: .white, location: 0.8367),
							.init(color: .white.opacity(0.20), location: 1.5517)
						],
						startPoint: .bottom,
						endPoint: .top
					),
					lineWidth: 1
				)
		}
        .frame(maxWidth: .infinity)
		.padding(.horizontal, 20)
	}

	// MARK: - Discussion

	private var discussionSection: some View {
		VStack(spacing: 0) {
			ForEach(Array(discussion.topics.enumerated()), id: \.element.id) { index, topic in
				topicRow(topic)
					.fixedSize(horizontal: false, vertical: true)
				if index < discussion.topics.count - 1 {
					dashedDivider
				}
			}
		}
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
		.background(
			LinearGradient(
				stops: [
					.init(color: .white, location: 0.8367),
					.init(color: .white.opacity(0.20), location: 1.5517)
				],
				startPoint: .bottom,
				endPoint: .top
			),
			in: RoundedRectangle(cornerRadius: 8)
		)
		.padding(.horizontal, 19)
	}

	private var dashedDivider: some View {
		HorizontalLine()
			.stroke(Color.gray300, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
			.frame(height: 1)
            .padding(.vertical, 12)
	}

	private struct HorizontalLine: Shape {
		func path(in rect: CGRect) -> Path {
			Path { path in
				path.move(to: CGPoint(x: rect.minX, y: rect.midY))
				path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
			}
		}
	}

	private func topicRow(_ topic: DiscussionTopic) -> some View {
		HStack(alignment: .top, spacing: 0) {
			VStack(alignment: .leading, spacing: 6) {
				Text(String(format: "%02d", topic.id))
					.pointText1Style
					.foregroundStyle(Color.green700)
                    .padding(.bottom, 4)
				Rectangle()
					.frame(width: 24, height: 1)
					.foregroundStyle(Color.green700)
			}
            
			Rectangle()
				.frame(width: 1)
				.foregroundStyle(Color.gray300)
                .padding(.horizontal, 10)

			VStack(alignment: .leading, spacing: 0) {
				Text(topic.question)
					.body2SemiBoldStyle
					.foregroundStyle(Color.gray800)
                    .padding(.bottom, 8)
				Text(topic.content)
					.caption1RegularStyle
					.foregroundStyle(Color.gray500)
                    .padding(.bottom, 11)
			}
            .padding(.trailing, 7)
		}
	}

	// MARK: - Helpers

	private static let dateFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = "MM/dd"
		return f
	}()

	private static let dateTimeFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = "MM/dd HH:mm"
		return f
	}()
}

#Preview {
	NavigationStack {
		BookMeetingResultView(
			meeting: BookMeeting(
				id: 1,
				book: Book(
					id: 1,
					title: "빛은 얼마나 깊이 스미는가",
					author: "사브리나 임볼리"
				),
				readingStartDate: Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 25)) ?? Date(),
				readingEndDate: Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 28)) ?? Date(),
				meetingDate: Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 30, hour: 19)) ?? Date(),
				timerMinutes: 30,
				maxParticipants: 6,
				currentParticipants: 6,
				status: .completed
			)
		)
	}
}
