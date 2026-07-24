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
      headerView

      ScrollView(showsIndicators: false) {
        VStack(spacing: 0) {
          noticeBannerView
          questionView

          VStack(spacing: 44) {
            ForEach(messages) { message in
              ChatMessageView(
                nickname: message.nickname,
                message: message.message,
                time: message.time,
                isMyMessage: message.isMyMessage,
                profileImageName: message.profileImageName
              )
            }
          }
          .padding(.top, 40)
          .padding(.horizontal, 30)
          .padding(.bottom, 16)
        }
      }
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
          .body2SemiBoldStyle
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
            .scaledToFit()
            .frame(width: 14, height: 12)
          Text("2/4")
            .caption1RegularStyle
        }
        .foregroundStyle(.gray600)
        .frame(width: 72, height: 24)
        .background(.white)
        .clipShape(Capsule())
        .overlay {
          Capsule()
            .stroke(.gray200, lineWidth: 1)
        }

        HStack(spacing: 4) {
          Image("time_icon")
            .resizable()
            .scaledToFit()
            .frame(width: 13, height: 13)
          Text("24:13")
            .caption1RegularStyle
        }
        .foregroundStyle(.gray600)
        .frame(width: 72, height: 24)
        .background(.white)
        .clipShape(Capsule())
        .overlay {
          Capsule()
            .stroke(.gray200, lineWidth: 1)
        }

        Image("siren_icon")
          .resizable()
          .scaledToFit()
          .frame(width: 18, height: 22.6)
          .foregroundStyle(.gray600)
          .padding(.leading, 4)
      }
    }
    .padding(.horizontal, 30)
    .padding(.vertical, 12)
  }

  // MARK: - Notice Banner

  private var noticeBannerView: some View {
    HStack(spacing: 6) {
      Image("star_icon")
        .resizable()
        .scaledToFit()
        .frame(width: 14, height: 14)
      Text("이 대화방은 24분 후 사라집니다.")
        .caption2RegularStyle
        .foregroundStyle(.gray700)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 7)
    .background(.white)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .shadow(color: .black.opacity(0.1), radius: 2, x: -2, y: 2)
    .padding(.horizontal, 37)
    .padding(.top, 22)
  }

  // MARK: - Question

  private var questionView: some View {
    HStack {
      Image(systemName: "leaf.fill")
        .foregroundStyle(.green700)
      Text("첫번째 질문 보기")
        .body2SemiBoldStyle
        .foregroundStyle(.green600)
      Spacer()
      Image(systemName: "chevron.down")
        .foregroundStyle(.green700)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 18)
    .background(
      LinearGradient(
        stops: [
          Gradient.Stop(color: Color(hex: "CCE1D2"), location: 0),
          Gradient.Stop(color: Color(hex: "CCE1D2").opacity(0.4), location: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
      )
    )
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay {
      RoundedRectangle(cornerRadius: 12)
        .stroke(.white, lineWidth: 1)
    }
    .shadow(color: .black.opacity(0.1), radius: 4, x: -4, y: 4)
    .padding(.horizontal, 20)
    .padding(.top, 17.29)
  }
}

#Preview {
  ChatView()
}
