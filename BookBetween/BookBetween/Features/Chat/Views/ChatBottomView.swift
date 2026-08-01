//
//  ChatBottomView.swift
//  BookBetween
//
//  Created by 한지민 on 7/4/26.
//

import SwiftUI

struct ChatBottomView: View {

  // MARK: - Metric

  private enum Metric {
    static let containerSpacing: CGFloat = 12
    static let containerHorizontalPadding: CGFloat = 13
    static let containerVerticalPadding: CGFloat = 14
    static let cornerRadius: CGFloat = 12
    static let borderWidth: CGFloat = 1

    static let starIconSize: CGFloat = 20
    static let starIconTrailingPadding: CGFloat = 8
    static let requestTextSpacing: CGFloat = 5

    static let smallCaptionTracking: CGFloat = -0.036
    static let smallCaptionLineSpacing: CGFloat = 8

    static let countIconSize: CGFloat = 12
    static let countBadgeHorizontalPadding: CGFloat = 10
    static let countBadgeWidth: CGFloat = 60
    static let countBadgeHeight: CGFloat = 24

    static let requestRowHorizontalPadding: CGFloat = 13
    static let requestRowTopPadding: CGFloat = 14
    static let requestRowBottomPadding: CGFloat = 15
    static let requestRowGradientStartLocation: CGFloat = 0
    static let requestRowGradientEndLocation: CGFloat = 1.9
    static let requestRowGradientColorHex: String = "DFEBFC"
    static let thinBorderWidth: CGFloat = 0.5

    static let messageInputSpacing: CGFloat = 12
    static let textFieldVerticalPadding: CGFloat = 9.5
    static let sendButtonSize: CGFloat = 35
    static let sendButtonVerticalPadding: CGFloat = 2
    static let messageInputLeadingPadding: CGFloat = 16
    static let messageInputTrailingPadding: CGFloat = 4
  }

  // MARK: - Properties

  @Binding var messageText: String
  var isFocused: FocusState<Bool>.Binding
  let currentQuestionCount: Int
  let maxQuestionCount: Int
  let onRequestQuestionTap: () -> Void
  let onSendTap: () -> Void
  let isRequestQuestionDisabled: Bool

  // MARK: - Body

  var body: some View {
    VStack(spacing: Metric.containerSpacing) {
      self.questionRequestRow
      self.messageInputRow
    }
    .padding(.horizontal, Metric.containerHorizontalPadding)
    .padding(.top, Metric.containerVerticalPadding)
    .padding(.bottom, Metric.containerVerticalPadding)
    .background(.white)
    .clipShape(RoundedRectangle(cornerRadius: Metric.cornerRadius))
    .overlay {
      RoundedRectangle(cornerRadius: Metric.cornerRadius)
        .stroke(.gray200, lineWidth: Metric.borderWidth)
    }
  }

  // MARK: - Question Request

  private var questionRequestRow: some View {
    Button(action: self.onRequestQuestionTap) {
      HStack(spacing: 0) {
        Image("star_icon")
          .resizable()
          .scaledToFit()
          .frame(width: Metric.starIconSize, height: Metric.starIconSize)
          .padding(.trailing, Metric.starIconTrailingPadding)

        VStack(alignment: .leading, spacing: Metric.requestTextSpacing) {
          Text("질문 생성 요청하기")
            .font(.caption1SemiBold)
            .tracking(Metric.smallCaptionTracking) // 자간 -0.3%
            .lineSpacing(Metric.smallCaptionLineSpacing) // 행간 20pt (12pt 기준 +8)
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
            .frame(width: Metric.countIconSize, height: Metric.countIconSize)
            .foregroundStyle(.blue600)
          Text("\(self.currentQuestionCount)/\(self.maxQuestionCount)")
            .font(.caption1SemiBold)
            .tracking(Metric.smallCaptionTracking) // 자간 -0.3%
            .lineSpacing(Metric.smallCaptionLineSpacing) // 행간 20pt (12pt 기준 +8)
            .foregroundStyle(.blue600)
        }
        .padding(.horizontal, Metric.countBadgeHorizontalPadding)
        .frame(width: Metric.countBadgeWidth, height: Metric.countBadgeHeight)
        .background(.white)
        .clipShape(Capsule())
        .shadow1()
      }
      .padding(.leading, Metric.requestRowHorizontalPadding)
      .padding(.trailing, Metric.requestRowHorizontalPadding)
      .padding(.top, Metric.requestRowTopPadding)
      .padding(.bottom, Metric.requestRowBottomPadding)
      .background(
        // linear-gradient(180deg, #DFEBFC 0%, #FFF 190%)
        LinearGradient(
          gradient: Gradient(stops: [
            .init(
              color: Color(hex: Metric.requestRowGradientColorHex),
              location: Metric.requestRowGradientStartLocation
            ),
            .init(color: .white, location: Metric.requestRowGradientEndLocation)
          ]),
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .clipShape(RoundedRectangle(cornerRadius: Metric.cornerRadius))
      .overlay {
        RoundedRectangle(cornerRadius: Metric.cornerRadius)
          .stroke(.blue50, lineWidth: Metric.thinBorderWidth)
      }
      .compositingGroup()
    }
    .buttonStyle(.plain)
    .disabled(self.isRequestQuestionDisabled)
  }

  // MARK: - Message Input

  private var messageInputRow: some View {
    HStack(spacing: Metric.messageInputSpacing) {
      TextField("메시지 입력", text: self.$messageText)
        .font(.caption1SemiBold)
        .tracking(Metric.smallCaptionTracking) // 자간 -0.3%
        .lineSpacing(Metric.smallCaptionLineSpacing) // 행간 20pt (12pt 기준 +8)
        .foregroundStyle(.gray300)
        .padding(.vertical, Metric.textFieldVerticalPadding)
        .focused(self.isFocused)

      Button(action: self.onSendTap) {
        Image("direct_icon")
          .resizable()
          .scaledToFit()
          .frame(width: Metric.sendButtonSize, height: Metric.sendButtonSize)
      }
      .padding(.vertical, Metric.sendButtonVerticalPadding)
    }
    .padding(.leading, Metric.messageInputLeadingPadding)
    .padding(.trailing, Metric.messageInputTrailingPadding)
    .background(.white)
    .clipShape(RoundedRectangle(cornerRadius: Metric.cornerRadius))
    .overlay {
      RoundedRectangle(cornerRadius: Metric.cornerRadius)
        .stroke(.gray300, lineWidth: Metric.thinBorderWidth)
    }
  }
}

#Preview {
  @Previewable @FocusState var isFocused: Bool

  ChatBottomView(
    messageText: .constant(""),
    isFocused: $isFocused,
    currentQuestionCount: 2,
    maxQuestionCount: 5,
    onRequestQuestionTap: {},
    onSendTap: {},
    isRequestQuestionDisabled: false
  )
  .padding()
  .background(.gray50)
}
