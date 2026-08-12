//
//  MeetingEndedModalView.swift
//  BookBetween
//
//  Created by 한지민 on 7/26/26.
//

import SwiftUI

struct MeetingEndedModalView: View {
  let meeting: BookMeeting
  var onGoHome: () -> Void = {}

  var body: some View {
    VStack(spacing: 0) {
      self.checkIcon
        .padding(.top, 24.5)

      VStack(spacing: 8) {
        Text("독서모임이 종료되었습니다")
          .font(.pretend(type: .semiBold, size: 18))
          .tracking(-0.054)
          .lineSpacing(2)
          .foregroundStyle(Color.green900)
          .multilineTextAlignment(.center)

        VStack(spacing: 4) {
          Text("모임 종료 후 모든 대화 내용이 삭제됩니다")
            .font(.pretend(type: .semiBold, size: 14))
            .tracking(-0.042)
            .lineSpacing(6)
            .foregroundStyle(Color.gray500)
            .multilineTextAlignment(.center)

          Text("모임 내용은 AI가 요약하여 알려드릴게요")
            .font(.pretend(type: .semiBold, size: 14))
            .tracking(-0.042)
            .lineSpacing(6)
            .foregroundStyle(Color.gray500)
            .multilineTextAlignment(.center)
        }
      }
      .padding(.top, -20.03)

      self.meetingCard
        .padding(.top, 16)

      self.goHomeButton
        .padding(.top, 16)
    }
    .padding(.horizontal, 20)
    .padding(.bottom, 20)
    .frame(width: 300, height: 350)
    .background {
      LinearGradient(
        stops: [
          Gradient.Stop(color: .white, location: 0.8367),
          Gradient.Stop(color: Color.white.opacity(0.2), location: 1.5517)
        ],
        startPoint: .bottom,
        endPoint: .top
      )
    }
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay {
      RoundedRectangle(cornerRadius: 12)
        .strokeBorder(
          LinearGradient(
            stops: [
              Gradient.Stop(color: Color.white.opacity(0.2), location: 0.2499),
              Gradient.Stop(color: .white, location: 0.8197)
            ],
            startPoint: UnitPoint(x: 0.967, y: 0.321),
            endPoint: UnitPoint(x: 0.033, y: 0.679)
          ),
          lineWidth: 1.5
        )
    }
    .shadow(color: Color(hex: "2B2A28").opacity(0.16), radius: 24, x: 0, y: 20)
  }

  // MARK: - checkIcon

  private var checkIcon: some View {
    Image("icon_check_mark")
      .resizable()
      .scaledToFit()
      .frame(width: 50, height: 44)
      .shadow(color: Color(hex: "205130").opacity(0.2), radius: 2, x: -4, y: 4)
      .offset(y: -3)
      .frame(width: 120, height: 120)
      .background {
        RadialGradient(
          stops: [
            Gradient.Stop(color: Color.green50.opacity(0.5), location: 0.51),
            Gradient.Stop(color: Color.white.opacity(0), location: 1.0)
          ],
          center: UnitPoint(x: 0.5, y: 0.46875),
          startRadius: 0,
          endRadius: 70
        )
        .frame(width: 160, height: 160)
      }
  }

  // MARK: - meetingCard

  private var meetingCard: some View {
    HStack(alignment: .center, spacing: 12) {
      BookCoverImage(book: self.meeting.book, placeholderImageName: "book_cover_mock")
        .aspectRatio(40.476 / 59.389, contentMode: .fill)
        .frame(width: 40.476, height: 59.389)
        .clipShape(RoundedRectangle(cornerRadius: 5.569))
        .padding(.leading, 24)
        .padding(.top, 6.81)
        .padding(.bottom, 6.86)

      VStack(alignment: .leading, spacing: 0) {
        Text(self.meeting.book.title)
          .body2SemiBoldStyle
          .foregroundStyle(Color.gray800)
          .lineLimit(1)
          .padding(.top, 9)

        Text(self.meeting.book.author)
          .caption1RegularStyle
          .foregroundStyle(Color.gray500)
          .padding(.top, 4)
          .padding(.bottom, 2)

        self.infoRow
          .padding(.top, 1.99)
      }
      .padding(.bottom, 9.87)

      Spacer()
    }
    .frame(width: 240, height: 73.059)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 7.016))
    .overlay {
      RoundedRectangle(cornerRadius: 7.016)
        .stroke(Color.gray300, lineWidth: 0.292)
    }
  }

  private var infoRow: some View {
    HStack(spacing: 3.694) {
      Image("icon_calendar")
        .resizable()
        .scaledToFill()
        .frame(width: 9.605, height: 9.605)
        .clipped()

      Text(self.meetingDateText)
        .font(.pretend(type: .regular, size: 8.866))
        .tracking(-0.027)
        .lineSpacing(5.911)

      Image("icon_divider")
        .resizable()
        .frame(width: 0.739, height: 8)

      Image("icon_group")
        .resizable()
        .scaledToFill()
        .frame(width: 8.127, height: 7.388)
        .clipped()

      Text("\(self.meeting.currentParticipants)/\(self.meeting.maxParticipants)")
        .font(.pretend(type: .regular, size: 8.866))
        .tracking(-0.027)
        .lineSpacing(5.911)
    }
    .foregroundStyle(Color.gray600)
  }

  // MARK: - goHomeButton

  private var goHomeButton: some View {
    Button(action: self.onGoHome) {
      Text("홈으로 이동")
        .body1SemiBoldStyle
        .foregroundStyle(Color.beige100)
        .padding(.vertical, 13)
        .padding(.horizontal, 82)
        .frame(width: 240)
        .background(Color.green600)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }

  // MARK: - Helpers

  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "MM/dd · HH:mm"
    return formatter
  }()

  private var meetingDateText: String {
    Self.dateFormatter.string(from: self.meeting.meetingDate)
  }
}

#Preview {
  MeetingEndedModalView(
    meeting: BookMeeting(
      id: 1,
      book: Book(
        id: 1,
        title: "혼모노",
        author: "성해나"
      ),
      meetingDate: Calendar.current.date(
        from: DateComponents(year: 2026, month: 6, day: 20, hour: 6)
      ) ?? Date(),
      timerMinutes: 30,
      maxParticipants: 6,
      currentParticipants: 4,
      status: .completed
    )
  )
  .padding(.horizontal, 24)
}
