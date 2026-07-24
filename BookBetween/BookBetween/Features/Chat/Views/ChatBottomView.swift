//
//  ChatBottomView.swift
//  BookBetween
//
//  Created by 한지민 on 7/4/26.
//

import SwiftUI

struct ChatBottomView: View {
  @Binding var messageText: String
  let currentQuestionCount: Int
  let maxQuestionCount: Int
  let onRequestQuestionTap: () -> Void
  let onSendTap: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      self.questionRequestRow
      self.messageInputRow
    }
    .padding(.horizontal, 13)
    .padding(.top, 14)
    .padding(.bottom, 14)
    .background(.white)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay {
      RoundedRectangle(cornerRadius: 12)
        .stroke(.gray200, lineWidth: 1)
    }
  }

  // MARK: - Question Request

  private var questionRequestRow: some View {
    Button(action: self.onRequestQuestionTap) {
      HStack(spacing: 0) {
        Image("star_icon")
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .padding(.trailing, 8)

        VStack(alignment: .leading, spacing: 5) {
          Text("질문 생성 요청하기")
            .font(.caption1SemiBold)
            .tracking(-0.036) // 자간 -0.3%
            .lineSpacing(8) // 행간 20pt (12pt 기준 +8)
            .foregroundStyle(.blue600)
          Text("한 채팅 당 5개의 질문이 생성돼요")
            .caption2RegularStyle
            .foregroundStyle(.gray600)
        }

        Spacer()

        HStack(spacing: 4) {
          Image("people_icon")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: 12, height: 12)
            .foregroundStyle(.blue600)
          Text("\(self.currentQuestionCount)/\(self.maxQuestionCount)")
            .font(.caption1SemiBold)
            .tracking(-0.036) // 자간 -0.3%
            .lineSpacing(8) // 행간 20pt (12pt 기준 +8)
            .foregroundStyle(.blue600)
        }
        .padding(.horizontal, 10)
        .frame(width: 60, height: 24)
        .background(.white)
        .clipShape(Capsule())
        .shadow1()
      }
      .padding(.leading, 13)
      .padding(.trailing, 13)
      .padding(.top, 14)
      .padding(.bottom, 15)
      .background(
        // linear-gradient(180deg, #DFEBFC 0%, #FFF 190%)
        LinearGradient(
          gradient: Gradient(stops: [
            .init(color: Color(hex: "DFEBFC"), location: 0),
            .init(color: .white, location: 1.9)
          ]),
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .overlay {
        RoundedRectangle(cornerRadius: 12)
          .stroke(.blue50, lineWidth: 0.5)
      }
    }
    .buttonStyle(.plain)
  }

  // MARK: - Message Input

  private var messageInputRow: some View {
    HStack(spacing: 12) {
      TextField("메시지 입력", text: self.$messageText)
        .font(.caption1SemiBold)
        .tracking(-0.036) // 자간 -0.3%
        .lineSpacing(8) // 행간 20pt (12pt 기준 +8)
        .foregroundStyle(.gray300)
        .padding(.vertical, 9.5)

      Button(action: self.onSendTap) {
        Image("direct_icon")
          .resizable()
          .scaledToFit()
          .frame(width: 35, height: 35)
      }
      .padding(.vertical, 2)
    }
    .padding(.leading, 16)
    .padding(.trailing, 4)
    .background(.white)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay {
      RoundedRectangle(cornerRadius: 12)
        .stroke(.gray300, lineWidth: 0.5)
    }
  }
}

#Preview {
  ChatBottomView(
    messageText: .constant(""),
    currentQuestionCount: 2,
    maxQuestionCount: 5,
    onRequestQuestionTap: {},
    onSendTap: {}
  )
  .padding()
  .background(.gray50)
}
