//
//  MeetingCardView.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import SwiftUI
import Foundation

struct MeetingCardView: View {
    let meeting: BookMeeting
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(meeting.book.thumbnailImageName ?? "book_cover_meeting_1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 108)
                    .shadow(color: .black.opacity(0.1), radius: 1.19453, x: -2.38905, y: 2.38905)

                VStack(alignment: .leading, spacing: 7) {
                    Text(meeting.status.title)
                        .caption1SemiBoldStyle
                        .foregroundStyle(.green600)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.green50)
                        .clipShape(Capsule())
                        .offset(y: 4)
                    
                    
                    Text(meeting.book.title)
                        .head3Style
                        //.lineLimit(1)
                    
                    HStack {
                        Image("icon_calendar")
                            .padding(3)
                            .background(.green50)
                            .clipShape(.circle)
                        
                        Text(meetingDateText)
                            .caption2RegularStyle
                    }
                    .foregroundStyle(.gray500)
                    
                    HStack(spacing: 8) {
                        Image("icon_group")
                            .padding(3)
                            .background(.green50)
                            .clipShape(.circle)
                        Text("\(meeting.currentParticipants)/\(meeting.maxParticipants)명 참여 중")
                            .caption2RegularStyle
                    }
                    .foregroundStyle(.gray500)
                }
                
                .padding(.leading, 35)
                Spacer()
            }
            .padding(.leading, 25)
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
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray300, lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 3)
    }

    private var meetingDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM/dd (E) · HH:mm"
        return formatter.string(from: meeting.meetingDate)
    }
}

#Preview {
    MeetingCardView(
        meeting: BookMeeting(
            id: "meeting-1",
            book: Book(
                id: "meeting-book-1",
                title: "빛은 얼마나 깊이 스미는가",
                author: "",
                description: nil,
                thumbnailURL: nil,
                thumbnailImageName: "book_cover_meeting_1"
            ),
            title: nil,
            description: "",
            recruitmentStartDate: Date(),
            recruitmentEndDate: Date(),
            readingStartDate: Date(),
            readingEndDate: Date(),
            meetingDate: Date(),
            timerMinutes: 60,
            maxParticipants: 6,
            currentParticipants: 2,
            status: .recruiting
        )
    )
}
