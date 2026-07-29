//
//  MeetingStartedModalView.swift
//  BookBetween
//
//  Created by 한지민 on 7/26/26.
//

import SwiftUI

struct MeetingStartedModalView: View {
  let meeting: BookMeeting
  var onClose: () -> Void = {}
  var onParticipate: () -> Void = {}

  var body: some View {
    VStack(spacing: 0) {
      self.bellIcon
        .padding(.top, 24.5)

      VStack(spacing: 4) {
        Text("독서모임이 시작되었습니다.")
          .head3Style
          .foregroundStyle(Color.green900)
          .multilineTextAlignment(.center)

        Text("지금 참여하여 함께 이야기를 나눠보세요.")
          .body2SemiBoldStyle
          .foregroundStyle(Color.gray500)
          .multilineTextAlignment(.center)
      }
      .padding(.top, -7.681)

      self.meetingCard
        .padding(.top, 12)

      self.participateButton
        .padding(.top, 12)
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 24.5)
    .frame(width: 300, height: 340)
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
    .overlay(alignment: .top) {
      self.closeButton
    }
    .shadow(color: Color(hex: "2B2A28").opacity(0.16), radius: 24, x: 0, y: 20)
  }

  // MARK: - closeButton

  private var closeButton: some View {
    HStack {
      Spacer()
      Button(action: self.onClose) {
        Image("close_icon")
          .resizable()
          .frame(width: 24, height: 24)
      }
    }
    .padding(.top, 10)
  }

  // MARK: - bellIcon

  private var bellIcon: some View {
    Image("icon_alert_mark")
      .resizable()
      .scaledToFit()
      .frame(width: 50, height: 54.362)
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

  // MARK: - participateButton

  private var participateButton: some View {
    Button(action: self.onParticipate) {
      Text("참여하기")
        .body1SemiBoldStyle
        .foregroundStyle(Color.beige100)
        .frame(width: 240, height: 40)
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
  MeetingStartedModalView(
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
      status: .inProgress
    )
  )
  .padding(.horizontal, 24)
}
