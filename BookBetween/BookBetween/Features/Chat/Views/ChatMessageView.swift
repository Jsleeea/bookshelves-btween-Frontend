//
//  ChatMessageView.swift
//  BookBetween
//
//  Created by 한지민 on 7/4/26.
//

import SwiftUI

struct ChatMessageView: View {

  // MARK: - Metric

  private enum Metric {
    static let rowSpacing: CGFloat = 4
    static let timeTracking: CGFloat = -0.03
    static let timeLineSpacing: CGFloat = 6
    static let timeOffsetY: CGFloat = 1.57

    static let bubbleHorizontalPadding: CGFloat = 10
    static let bubbleVerticalPadding: CGFloat = 5
    static let bubbleRoundedCornerRadius: CGFloat = 18.64
    static let bubbleSharpCornerRadius: CGFloat = 6.21

    static let profileImageSize: CGFloat = 34.99
    static let contentSpacing: CGFloat = 3
    static let captionTracking: CGFloat = -0.036
    static let captionLineSpacing: CGFloat = 8
    static let nicknameLeadingPadding: CGFloat = 4.14

    static let bubbleMinHeight: CGFloat = 32
    static let otherBubbleBorderWidth: CGFloat = 1
    static let otherBubbleTextColorHex: String = "1E2B34"
  }

  // MARK: - Properties

  let nickname: String
  let message: String
  let time: String
  let isMyMessage: Bool
  let profileAnimalName: String
  let profileBackgroundColor: ProfileBackgroundColorCode

  // MARK: - Body

  var body: some View {
    if self.isMyMessage {
      self.myMessageView
    } else {
      self.otherMessageView
    }
  }

  // MARK: - My Message

  private var myMessageView: some View {
    HStack(alignment: .bottom, spacing: Metric.rowSpacing) {
      Text(self.time)
        .font(.caption2Regular)
        .tracking(Metric.timeTracking)
        .lineSpacing(Metric.timeLineSpacing)
        .foregroundStyle(.gray200)

      Text(self.message)
        .caption1RegularStyle
        .foregroundStyle(.white)
        .padding(.horizontal, Metric.bubbleHorizontalPadding)
        .padding(.vertical, Metric.bubbleVerticalPadding)
        .frame(minHeight: Metric.bubbleMinHeight)
        .background(.green500)
        .clipShape(
          UnevenRoundedRectangle(
            topLeadingRadius: Metric.bubbleRoundedCornerRadius,
            bottomLeadingRadius: Metric.bubbleRoundedCornerRadius,
            bottomTrailingRadius: Metric.bubbleRoundedCornerRadius,
            topTrailingRadius: Metric.bubbleSharpCornerRadius
          )
        )
    }
    .frame(maxWidth: .infinity, alignment: .trailing)
  }

  // MARK: - Other Message

  private var otherMessageView: some View {
    HStack(alignment: .top, spacing: Metric.rowSpacing) {
      Circle()
        .fill(self.profileBackgroundColor.profileGradient)
        .frame(width: Metric.profileImageSize, height: Metric.profileImageSize)
        .overlay {
          Image(NicknameGenerator.animalImageName(for: self.profileAnimalName))
            .resizable()
            .scaledToFit()
        }
        .clipShape(Circle())
        .shadow1()

      VStack(alignment: .leading, spacing: Metric.contentSpacing) {
        Text(self.nickname)
          .font(.caption1SemiBold)
          .tracking(Metric.captionTracking)
          .lineSpacing(Metric.captionLineSpacing)
          .foregroundStyle(.gray600)
          .padding(.leading, Metric.nicknameLeadingPadding)

        HStack(alignment: .bottom, spacing: Metric.rowSpacing) {
          Text(self.message)
            .font(.caption1Regular)
            .tracking(Metric.captionTracking)
            .lineSpacing(Metric.captionLineSpacing)
            .foregroundStyle(Color(hex: Metric.otherBubbleTextColorHex))
            .padding(.horizontal, Metric.bubbleHorizontalPadding)
            .padding(.vertical, Metric.bubbleVerticalPadding)
            .frame(minHeight: Metric.bubbleMinHeight)
            .background(.white)
            .clipShape(
              UnevenRoundedRectangle(
                topLeadingRadius: Metric.bubbleSharpCornerRadius,
                bottomLeadingRadius: Metric.bubbleRoundedCornerRadius,
                bottomTrailingRadius: Metric.bubbleRoundedCornerRadius,
                topTrailingRadius: Metric.bubbleRoundedCornerRadius
              )
            )
            .overlay {
              UnevenRoundedRectangle(
                topLeadingRadius: Metric.bubbleSharpCornerRadius,
                bottomLeadingRadius: Metric.bubbleRoundedCornerRadius,
                bottomTrailingRadius: Metric.bubbleRoundedCornerRadius,
                topTrailingRadius: Metric.bubbleRoundedCornerRadius
              )
              .stroke(.gray200, lineWidth: Metric.otherBubbleBorderWidth)
            }

          Text(self.time)
            .font(.caption2Regular)
            .tracking(Metric.timeTracking)
            .lineSpacing(Metric.timeLineSpacing)
            .foregroundStyle(.gray200)
            .offset(y: Metric.timeOffsetY)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  VStack(spacing: 44) {
    ChatMessageView(
      nickname: "책 먹는 곰",
      message: "모든 것이 하나로 흐르는 소리 같아요.",
      time: "06:27",
      isMyMessage: false,
      profileAnimalName: "곰",
      profileBackgroundColor: .brown
    )
    ChatMessageView(
      nickname: "",
      message: "저는 '쉼'이라는 단어가 떠올랐어요.",
      time: "06:27",
      isMyMessage: true,
      profileAnimalName: "",
      profileBackgroundColor: .brown
    )
    ChatMessageView(
      nickname: "문장 모으는 펭귄",
      message: "저는 강을 다시 읽고 싶어졌어요.",
      time: "06:27",
      isMyMessage: false,
      profileAnimalName: "펭귄",
      profileBackgroundColor: .blue
    )
    ChatMessageView(
      nickname: "책갈피 훔치는 판다",
      message: "저도 강을 다시 읽고 싶어졌어요.",
      time: "06:27",
      isMyMessage: false,
      profileAnimalName: "판다",
      profileBackgroundColor: .purple
    )
  }
  .padding()
  .background(.gray50)
}
