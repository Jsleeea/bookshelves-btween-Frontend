//
//  ChatView.swift
//  BookBetween
//
//  Created by 한지민 on 7/4/26.
//

import SwiftUI

struct ChatView: View {

  // MARK: - Metric

  private enum Metric {
    static let horizontalPadding: CGFloat = 20
    static let wideHorizontalPadding: CGFloat = 30
    static let cardCornerRadius: CGFloat = 12
    static let cardBorderWidth: CGFloat = 1

    static let messageListSpacing: CGFloat = 20
    static let messageListTopPadding: CGFloat = 32
    static let messageListBottomPadding: CGFloat = 16

    static let chatBottomTopPadding: CGFloat = 44
    static let chatBottomBottomPadding: CGFloat = 12
    static let backgroundTopColorHex: String = "F0F7FD"

    static let downButtonSize: CGFloat = 30
    static let downButtonCornerRadius: CGFloat = 20
    static let downButtonTrailingPadding: CGFloat = 28
    static let downButtonShadowRadius: CGFloat = 24
    static let downButtonShadowYOffset: CGFloat = 20
    static let downButtonShadowOpacity: CGFloat = 0.16
    static let downButtonShadowColorHex: String = "2B2A28"

    static let softGradientStartLocation: CGFloat = 0.8367
    static let softGradientEndLocation: CGFloat = 1.5517

    static let headerTitleSpacing: CGFloat = 2
    static let headerTopPadding: CGFloat = 8.5
    static let headerBottomPadding: CGFloat = 12
    static let headerSpacerMinLength: CGFloat = 76
    static let bodyTextTracking: CGFloat = -0.042
    static let bodyTextLineSpacing: CGFloat = 6

    static let badgeGroupSpacing: CGFloat = 4
    static let badgeWidth: CGFloat = 72
    static let badgeHeight: CGFloat = 24
    static let peopleIconWidth: CGFloat = 13
    static let peopleIconHeight: CGFloat = 12
    static let timeIconSize: CGFloat = 12
    static let captionTracking: CGFloat = -0.036
    static let captionLineSpacing: CGFloat = 8

    static let sirenIconWidth: CGFloat = 18
    static let sirenIconHeight: CGFloat = 22
    static let sirenLeadingPadding: CGFloat = 4
    static let sirenShadowOpacity: CGFloat = 0.25
    static let sirenShadowRadius: CGFloat = 4
    static let sirenShadowYOffset: CGFloat = 4

    static let starIconSize: CGFloat = 14
    static let starIconTrailingPadding: CGFloat = 4
    static let chevronWidth: CGFloat = 14
    static let chevronHeight: CGFloat = 7
    static let chevronVerticalPadding: CGFloat = 21
    static let chevronTrailingPadding: CGFloat = 21
    static let questionRowLeadingPadding: CGFloat = 20
    static let questionRowHeight: CGFloat = 49
    static let questionGradientColorHex: String = "CCE1D2"

    // 헤더 행이 49pt로 고정돼 텍스트가 중앙 정렬되며 생기는 여백(14pt)을 상쇄해
    // 실제 보이는 간격을 10pt로 맞추기 위한 값 (10 - 14 = -4)
    static let expandedContentSpacing: CGFloat = -4
    static let expandedParagraphBottomPadding: CGFloat = 20
  }

  // MARK: - Types

  private struct ChatMessage: Identifiable {
    let id = UUID()
    let nickname: String
    let message: String
    let time: String
    let isMyMessage: Bool
    let profileImageName: String?
  }

  // MARK: - Properties

  @State private var messageText: String = ""
  @State private var isQuestionExpanded: Bool = false
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

  // MARK: - Body

  var body: some View {
    VStack(spacing: 0) {
      self.headerView

      ScrollView(showsIndicators: false) {
        ZStack(alignment: .top) {
          VStack(spacing: 0) {
            self.questionView

            VStack(spacing: Metric.messageListSpacing) {
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
            .padding(.top, Metric.messageListTopPadding)
            .padding(.horizontal, Metric.wideHorizontalPadding)
            .padding(.bottom, Metric.messageListBottomPadding)
          }

          // ZStack의 나중 자식이라 항상 채팅 목록 위에 그려짐이 보장됨
          if self.isQuestionExpanded {
            self.expandedQuestionView
              .padding(.horizontal, Metric.horizontalPadding)
              .padding(.top, Metric.horizontalPadding)
          }
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
          .frame(width: Metric.downButtonSize, height: Metric.downButtonSize)
          .background(
            LinearGradient(
              stops: [
                Gradient.Stop(color: .white, location: Metric.softGradientStartLocation),
                Gradient.Stop(
                  color: .white.opacity(0.2),
                  location: Metric.softGradientEndLocation
                )
              ],
              startPoint: .bottom,
              endPoint: .top
            )
          )
          .clipShape(RoundedRectangle(cornerRadius: Metric.downButtonCornerRadius))
          .shadow(
            color: Color(hex: Metric.downButtonShadowColorHex)
              .opacity(Metric.downButtonShadowOpacity),
            radius: Metric.downButtonShadowRadius,
            x: 0,
            y: Metric.downButtonShadowYOffset
          )
          .padding(.trailing, Metric.downButtonTrailingPadding)
          .offset(y: -(Metric.downButtonSize + Metric.chatBottomBottomPadding))
      }
      .padding(.horizontal, Metric.horizontalPadding)
      .padding(.top, Metric.chatBottomTopPadding)
      .padding(.bottom, Metric.chatBottomBottomPadding)
    }
    .background(
      LinearGradient(
        colors: [Color(hex: Metric.backgroundTopColorHex), .white],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()
    )
    .toolbar(.hidden, for: .navigationBar)
    .hideTabBar()
  }

  // MARK: - Header

  private var headerView: some View {
    HStack {
      VStack(alignment: .leading, spacing: Metric.headerTitleSpacing) {
        Text("익명 독서 대화방")
          .font(.body2SemiBold)
          .tracking(Metric.bodyTextTracking)
          .lineSpacing(Metric.bodyTextLineSpacing)
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

      Spacer(minLength: Metric.headerSpacerMinLength)

      HStack(spacing: Metric.badgeGroupSpacing) {
        HStack(spacing: Metric.badgeGroupSpacing) {
          Image("people_icon")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: Metric.peopleIconWidth, height: Metric.peopleIconHeight)
          Text("2/4")
            .font(.caption1SemiBold)
            .tracking(Metric.captionTracking)
            .lineSpacing(Metric.captionLineSpacing)
        }
        .foregroundStyle(.gray600)
        .frame(width: Metric.badgeWidth, height: Metric.badgeHeight)
        .background(
          // linear-gradient(0deg, #FFF 83.67%, rgba(255, 255, 255, 0.20) 155.17%)
          LinearGradient(
            gradient: Gradient(stops: [
              .init(color: .white, location: Metric.softGradientStartLocation),
              .init(color: .white.opacity(0.2), location: Metric.softGradientEndLocation)
            ]),
            startPoint: .bottom,
            endPoint: .top
          )
        )
        .clipShape(Capsule())

        HStack(spacing: Metric.badgeGroupSpacing) {
          Image("icon_clock")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: Metric.timeIconSize, height: Metric.timeIconSize)
          Text("24:13")
            .font(.caption1SemiBold)
            .tracking(Metric.captionTracking)
            .lineSpacing(Metric.captionLineSpacing)
        }
        .foregroundStyle(.gray600)
        .frame(width: Metric.badgeWidth, height: Metric.badgeHeight)
        .background(
          // linear-gradient(0deg, #FFF 83.67%, rgba(255, 255, 255, 0.20) 155.17%)
          LinearGradient(
            gradient: Gradient(stops: [
              .init(color: .white, location: Metric.softGradientStartLocation),
              .init(color: .white.opacity(0.2), location: Metric.softGradientEndLocation)
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
          .frame(width: Metric.sirenIconWidth, height: Metric.sirenIconHeight)
          .foregroundStyle(.gray500)
          .shadow(
            color: .black.opacity(Metric.sirenShadowOpacity),
            radius: Metric.sirenShadowRadius,
            x: 0,
            y: Metric.sirenShadowYOffset
          )
          .padding(.leading, Metric.sirenLeadingPadding)
      }
    }
    .padding(.horizontal, Metric.wideHorizontalPadding)
    .padding(.top, Metric.headerTopPadding)
    .padding(.bottom, Metric.headerBottomPadding)
  }

  // MARK: - Question

  private var questionView: some View {
    HStack(spacing: 0) {
      Image("star_icon")
        .resizable()
        .renderingMode(.template)
        .scaledToFit()
        .frame(width: Metric.starIconSize, height: Metric.starIconSize)
        .foregroundStyle(.green600)
        .padding(.trailing, Metric.starIconTrailingPadding)
      Text("첫번째 질문 보기")
        .body2SemiBoldStyle
        .foregroundStyle(.green600)
      Spacer()
      Image("icon_chevron_down")
        .resizable()
        .renderingMode(.template)
        .scaledToFit()
        .frame(width: Metric.chevronWidth, height: Metric.chevronHeight)
        .foregroundStyle(.gray600)
        .rotationEffect(.degrees(self.isQuestionExpanded ? 180 : 0))
        .padding(.vertical, Metric.chevronVerticalPadding)
        .padding(.trailing, Metric.chevronTrailingPadding)
    }
    .padding(.leading, Metric.questionRowLeadingPadding)
    .frame(height: Metric.questionRowHeight)
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
            Gradient.Stop(color: Color(hex: Metric.questionGradientColorHex), location: 0),
            Gradient.Stop(
              color: Color(hex: Metric.questionGradientColorHex).opacity(0.4),
              location: 1.0
            )
          ],
          startPoint: .top,
          endPoint: .bottom
        )
        .opacity(0.8)
      }
    )
    .clipShape(RoundedRectangle(cornerRadius: Metric.cardCornerRadius))
    .overlay {
      RoundedRectangle(cornerRadius: Metric.cardCornerRadius)
        .stroke(.white, lineWidth: Metric.cardBorderWidth)
    }
    .shadow1()
    .opacity(self.isQuestionExpanded ? 0 : 1)
    .onTapGesture {
      withAnimation {
        self.isQuestionExpanded.toggle()
      }
    }
    .padding(.horizontal, Metric.horizontalPadding)
    .padding(.top, Metric.horizontalPadding)
  }

  // MARK: - Expanded Question

  private var expandedQuestionView: some View {
    VStack(alignment: .leading, spacing: Metric.expandedContentSpacing) {
      HStack(spacing: 0) {
        Image("star_icon")
          .resizable()
          .renderingMode(.template)
          .scaledToFit()
          .frame(width: Metric.starIconSize, height: Metric.starIconSize)
          .foregroundStyle(.green600)
          .padding(.trailing, Metric.starIconTrailingPadding)
        Text("첫번째 질문 보기")
          .body2SemiBoldStyle
          .foregroundStyle(.green600)
        Spacer()
        Image("icon_chevron_down")
          .resizable()
          .renderingMode(.template)
          .scaledToFit()
          .frame(width: Metric.chevronWidth, height: Metric.chevronHeight)
          .foregroundStyle(.gray600)
          .rotationEffect(.degrees(180))
          .padding(.vertical, Metric.chevronVerticalPadding)
          .padding(.trailing, Metric.chevronTrailingPadding)
      }
      .padding(.leading, Metric.questionRowLeadingPadding)
      .frame(height: Metric.questionRowHeight)

      Text("작품을 읽으며 가장 오래\n마음에 남은 장면은 무엇이었나요?")
        .font(.body2Regular)
        .tracking(Metric.bodyTextTracking)
        .lineSpacing(Metric.bodyTextLineSpacing)
        .foregroundStyle(.gray800)
        .padding(.horizontal, Metric.horizontalPadding)
        .padding(.bottom, Metric.expandedParagraphBottomPadding)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      Image("question_background")
        .resizable()
    )
    .fixedSize(horizontal: false, vertical: true)
    .shadow1()
    .onTapGesture {
      withAnimation {
        self.isQuestionExpanded.toggle()
      }
    }
  }
}

#Preview {
  ChatView()
}
