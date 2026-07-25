//
//  ChatView.swift
//  BookBetween
//
//  Created by 한지민 on 7/4/26.
//

import SwiftUI

struct ChatView: View {
  private struct ChatMessage: Identifiable {
    let id = UUID()
    let nickname: String
    let message: String
    let time: String
    let isMyMessage: Bool
    let profileImageName: String?
  }

  @State private var messageText: String = ""
  private let currentQuestionCount: Int = 2
  private let maxQuestionCount: Int = 5

  private let messages: [ChatMessage] = [
    ChatMessage(
      nickname: "조용한 두루미",
      message: "모든 것이 하나로 흐르는 소리 같아요.",
      time: "06:27",
      isMyMessage: false,
      profileImageName: nil
    ),
    ChatMessage(
      nickname: "",
      message: "저는 '쉼'이라는 단어가 떠올랐어요.",
      time: "06:27",
      isMyMessage: true,
      profileImageName: nil
    ),
    ChatMessage(
      nickname: "밤의 사슴",
      message: "저는 강을 다시 읽고 싶어졌어요.",
      time: "06:27",
      isMyMessage: false,
      profileImageName: nil
    ),
    ChatMessage(
      nickname: "새벽 고양이",
      message: "저도 강을 다시 읽고 싶어졌어요.",
      time: "06:27",
      isMyMessage: false,
      profileImageName: nil
    )
  ]

  var body: some View {
    VStack(spacing: 0) {
      self.headerView

      ScrollView(showsIndicators: false) {
        VStack(spacing: 0) {
          self.questionView

          VStack(spacing: 20) {
            ForEach(self.messages) { message in
              ChatMessageView(
                nickname: message.nickname,
                message: message.message,
                time: message.time,
                isMyMessage: message.isMyMessage,
                profileImageName: message.profileImageName
              )
            }
          }
          .padding(.top, 32)
          .padding(.horizontal, 30)
          .padding(.bottom, 16)
        }
      }

      ChatBottomView(
        messageText: self.$messageText,
        currentQuestionCount: self.currentQuestionCount,
        maxQuestionCount: self.maxQuestionCount,
        onRequestQuestionTap: {},
        onSendTap: {}
      )
      .overlay(alignment: .topTrailing) {
        Image("down_button")
          .resizable()
          .scaledToFit()
          .frame(width: 30, height: 30)
          .background(
            LinearGradient(
              stops: [
                Gradient.Stop(color: .white, location: 0.8367),
                Gradient.Stop(color: .white.opacity(0.2), location: 1.5517)
              ],
              startPoint: .bottom,
              endPoint: .top
            )
          )
          .clipShape(RoundedRectangle(cornerRadius: 20))
          .shadow(color: Color(hex: "2B2A28").opacity(0.16), radius: 24, x: 0, y: 20)
          .padding(.trailing, 28)
          .offset(y: -(30 + 20))
      }
      .padding(.horizontal, 20)
      .padding(.top, 44)
      .padding(.bottom, 12)
    }
    .background(
      LinearGradient(
        colors: [Color(hex: "F0F7FD"), .white],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()
    )
  }

  // MARK: - Header

  private var headerView: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text("익명 독서 대화방")
          .font(.body2SemiBold)
          .tracking(-0.042)
          .lineSpacing(6)
          .foregroundStyle(.gray600)
        HStack(spacing: 0) {
          Text("싯다르타 · ")
            .caption1RegularStyle
            .foregroundStyle(.gray500)
          Text("4/6")
            .caption1RegularStyle
            .foregroundStyle(.green500)
        }
      }

      Spacer(minLength: 76)

      HStack(spacing: 4) {
        HStack(spacing: 4) {
          Image("people_icon")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: 13, height: 12)
          Text("2/4")
            .font(.caption1SemiBold)
            .tracking(-0.036)
            .lineSpacing(8)
        }
        .foregroundStyle(.gray600)
        .frame(width: 72, height: 24)
        .background(
          // linear-gradient(0deg, #FFF 83.67%, rgba(255, 255, 255, 0.20) 155.17%)
          LinearGradient(
            gradient: Gradient(stops: [
              .init(color: .white, location: 0.8367),
              .init(color: .white.opacity(0.2), location: 1.5517)
            ]),
            startPoint: .bottom,
            endPoint: .top
          )
        )
        .clipShape(Capsule())

        HStack(spacing: 4) {
          Image("time_icon")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: 12, height: 12)
          Text("24:13")
            .font(.caption1SemiBold)
            .tracking(-0.036)
            .lineSpacing(8)
        }
        .foregroundStyle(.gray600)
        .frame(width: 72, height: 24)
        .background(
          // linear-gradient(0deg, #FFF 83.67%, rgba(255, 255, 255, 0.20) 155.17%)
          LinearGradient(
            gradient: Gradient(stops: [
              .init(color: .white, location: 0.8367),
              .init(color: .white.opacity(0.2), location: 1.5517)
            ]),
            startPoint: .bottom,
            endPoint: .top
          )
        )
        .clipShape(Capsule())

        Image("siren_icon")
          .resizable()
          .renderingMode(.template)
          .scaledToFit()
          .frame(width: 18, height: 22)
          .foregroundStyle(.gray500)
          .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4)
          .padding(.leading, 4)
      }
    }
    .padding(.horizontal, 30)
    .padding(.top, 8.5)
    .padding(.bottom, 12)
  }

  // MARK: - Question

  private var questionView: some View {
    HStack(spacing: 0) {
      Image("star_icon")
        .resizable()
        .renderingMode(.template)
        .scaledToFit()
        .frame(width: 14, height: 14)
        .foregroundStyle(.green600)
        .padding(.trailing, 4)
      Text("첫번째 질문 보기")
        .body2SemiBoldStyle
        .foregroundStyle(.green600)
      Spacer()
      Image("open_button")
        .resizable()
        .renderingMode(.template)
        .scaledToFit()
        .frame(width: 14, height: 7)
        .foregroundStyle(.gray600)
        .padding(.vertical, 21)
        .padding(.trailing, 21)
    }
    .padding(.leading, 20)
    .frame(height: 49)
    .background(
      ZStack {
        // 선형 100%: #FFFFFF 100% 0% -> #FFFFFF 40% 100%
        LinearGradient(
          stops: [
            Gradient.Stop(color: .white, location: 0),
            Gradient.Stop(color: .white.opacity(0.4), location: 1.0)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
        // 선형 80%: #CCE1D2 100% 0% -> #CCE1D2 40% 100%
        LinearGradient(
          stops: [
            Gradient.Stop(color: Color(hex: "CCE1D2"), location: 0),
            Gradient.Stop(color: Color(hex: "CCE1D2").opacity(0.4), location: 1.0)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
        .opacity(0.8)
      }
    )
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay {
      RoundedRectangle(cornerRadius: 12)
        .stroke(.white, lineWidth: 1)
    }
    .shadow1()
    .padding(.horizontal, 20)
    .padding(.top, 20)
  }
}

#Preview {
  ChatView()
}
