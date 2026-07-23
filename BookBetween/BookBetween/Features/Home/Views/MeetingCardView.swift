//
//  MeetingCardView.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import SwiftUI
import Foundation

struct MeetingCardView: View {
    let meeting: HomeMeetingItem
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BookCoverImage(
                    coverImageUrl: meeting.book.coverImageUrl,
                    placeholderImageName: "book_cover_meeting_1"
                )
                    .frame(width: 71, height: 108)

                VStack(alignment: .leading, spacing: 0) {
                    Text(meeting.book.title)
                        .head3Style
                        .lineLimit(1)
                    
                    HStack {
                        Image("icon_calendar")
                            .padding(3)
                            .background(.green50)
                            .clipShape(.circle)
                        
                        Text(meetingDateText)
                            .caption2RegularStyle
                    }
                    .foregroundStyle(.gray500)
                    .padding(.top, 20)
                    
                    HStack(spacing: 8) {
                        Image("icon_group")
                            .padding(3)
                            .background(.green50)
                            .clipShape(.circle)
                        Text("\(meeting.meeting.currentParticipants)/\(meeting.meeting.maxParticipants)명 참여 중")
                            .caption2RegularStyle
                    }
                    .foregroundStyle(.gray500)
                    .padding(.top, 6)
                }
                .padding(.leading, 35)
                Spacer()
            }
            .padding(.leading, 24)
            .padding(.top, 13)
            .padding(.bottom, 4)
            
            Button {
                
            } label: {
                HStack(spacing: 6) {
                    Text("참여하기")
                        .body2SemiBoldStyle
                    Image("icon_chevron_right_green")
                }
                .foregroundStyle(.green600)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .green400, location: 0.00),
                            Gradient.Stop(color: .green50, location: 1.00)
                        ],
                        startPoint: UnitPoint(x: 0.5, y: -0.3),
                        endPoint: UnitPoint(x: 0.5, y: 1.25)
                    )
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 2) // 참여하기 버튼 밑 흰색 여백
        .padding(.bottom, 2)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray300, lineWidth: 0.5)
        }
    }

    private var meetingDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM/dd (E) · HH:mm"
        return formatter.string(from: meeting.meeting.startDate)
    }
}

#Preview {
    MeetingCardView(
        meeting: HomeMeetingItem(
            meeting: HomeMeetingSummary(
                id: 21,
                status: "RECRUITING",
                startDate: Date(),
                currentParticipants: 2,
                maxParticipants: 6,
                duration: 30
            ),
            book: HomeMeetingBook(
                id: 1,
                title: "빛은 얼마나 깊이 스미는가",
                publisher: "창비",
                coverImageUrl: nil
            )
        )
    )
}
