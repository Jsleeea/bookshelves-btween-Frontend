//
//  ChatMessageView.swift
//  BookBetween
//
//  Created by 한지민 on 7/4/26.
//

import SwiftUI

struct ChatMessageView: View {
  let nickname: String
  let message: String
  let time: String
  let isMyMessage: Bool
  let profileImageName: String?

  var body: some View {
    if isMyMessage {
      myMessageView
    } else {
      otherMessageView
    }
  }

  // MARK: - My Message

  private var myMessageView: some View {
    HStack(alignment: .bottom, spacing: 4) {
      Text(time)
        .font(.caption2Regular)
        .tracking(-0.03)
        .lineSpacing(6)
        .foregroundStyle(.gray200)

      Text(message)
        .caption1RegularStyle
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.green500)
        .clipShape(
          UnevenRoundedRectangle(
            topLeadingRadius: 18.64,
            bottomLeadingRadius: 18.64,
            bottomTrailingRadius: 18.64,
            topTrailingRadius: 6.21
          )
        )
    }
    .frame(maxWidth: .infinity, alignment: .trailing)
  }

  // MARK: - Other Message

  private var otherMessageView: some View {
    HStack(alignment: .top, spacing: 4) {
      Circle()
        .fill(.gray300)
        .frame(width: 34.99, height: 34.99)
        .overlay {
          if let imageName = profileImageName {
            Image(imageName)
              .resizable()
              .scaledToFill()
              .clipShape(Circle())
          }
        }
        .shadow1()

      VStack(alignment: .leading, spacing: 3) {
        Text(nickname)
          .font(.caption1SemiBold)
          .tracking(-0.036)
          .lineSpacing(8)
          .foregroundStyle(.gray600)
          .padding(.leading, 4.14)

        HStack(alignment: .bottom, spacing: 4){
          Text(message)
            .font(.caption1Regular)
            .tracking(-0.036)
            .lineSpacing(8)
            .foregroundStyle(Color(hex: "1E2B34"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .frame(minHeight: 32)
            .background(.white)
            .clipShape(
              UnevenRoundedRectangle(
                topLeadingRadius: 6.21,
                bottomLeadingRadius: 18.64,
                bottomTrailingRadius: 18.64,
                topTrailingRadius: 18.64
              )
            )
            .overlay {
              UnevenRoundedRectangle(
                topLeadingRadius: 6.21,
                bottomLeadingRadius: 18.64,
                bottomTrailingRadius: 18.64,
                topTrailingRadius: 18.64
              )
              .stroke(.gray200, lineWidth: 1)
            }

          Text(time)
            .font(.caption2Regular)
            .tracking(-0.03)
            .lineSpacing(6)
            .foregroundStyle(.gray200)
            .offset(y: 1.57)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  VStack(spacing: 44) {
    ChatMessageView(
      nickname: "조용한 두루미",
      message: "모든 것이 하나로 흐르는 소리 같아요.",
      time: "06:27",
      isMyMessage: false,
      profileImageName: nil
    )
    ChatMessageView(
      nickname: "",
      message: "저는 '쉼'이라는 단어가 떠올랐어요.",
      time: "06:27",
      isMyMessage: true,
      profileImageName: nil
    )
    ChatMessageView(
      nickname: "밤의 사슴",
      message: "저는 강을 다시 읽고 싶어졌어요.",
      time: "06:27",
      isMyMessage: false,
      profileImageName: nil
    )
    ChatMessageView(
      nickname: "새벽 고양이",
      message: "저도 강을 다시 읽고 싶어졌어요.",
      time: "06:27",
      isMyMessage: false,
      profileImageName: nil
    )
  }
  .padding()
  .background(.gray50)
}
