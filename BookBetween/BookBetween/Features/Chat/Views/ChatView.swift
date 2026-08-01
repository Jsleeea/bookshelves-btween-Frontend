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

    static let chatBottomBottomPadding: CGFloat = 12
    static let backgroundTopColorHex: String = "F0F7FD"

    static let downButtonSize: CGFloat = 30
    static let downButtonCornerRadius: CGFloat = 20
    static let downButtonTrailingPadding: CGFloat = 28
    static let downButtonBottomPadding: CGFloat = 20
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

  private enum Identifier {
    static let bottomAnchor = "chat-bottom-anchor"
  }

  // MARK: - Formatter

  private static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter
  }()

  // MARK: - Properties

  @State private var viewModel: ChatViewModel
  @State private var messageText: String = ""
  @State private var isQuestionExpanded: Bool = false
  @State private var showsScrollToBottomButton: Bool = false
  @FocusState private var isMessageFieldFocused: Bool
  @Environment(\.dismiss) private var dismiss
  @Environment(\.scenePhase) private var scenePhase

  // MARK: - Init

  init(viewModel: ChatViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  init(chatroomId: Int, meetingId: Int) {
    _viewModel = State(
      initialValue: ChatViewModel(
        chatroomId: chatroomId,
        meetingId: meetingId,
        chatService: ChatService.stubbed(),
        socketService: ChatSocketService(
          configuration: NetworkConfiguration(
            baseURL: URL(string: "https://stub.bookbetween.local")!
          )
        )
      )
    )
  }

  // MARK: - Body

  var body: some View {
    VStack(spacing: 0) {
      self.headerView

      VStack(spacing: 0) {
        self.questionView

        ScrollViewReader { proxy in
          ScrollView(showsIndicators: false) {
            VStack(spacing: Metric.messageListSpacing) {
              ForEach(self.viewModel.messages) { message in
                ChatMessageView(
                  nickname: message.senderNickname,
                  message: message.content,
                  time: Self.timeFormatter.string(from: message.createdAt),
                  isMyMessage: message.senderMemberId == self.viewModel.myMemberId,
                  profileImageName: nil
                )
              }

              Color.clear
                .frame(height: 1)
                .id(Identifier.bottomAnchor)
            }
            .padding(.top, Metric.messageListTopPadding)
            .padding(.horizontal, Metric.wideHorizontalPadding)
            .padding(.bottom, Metric.messageListBottomPadding)
          }
          .safeAreaInset(edge: .bottom) {
            Color.clear
              .frame(height: Metric.downButtonSize + Metric.downButtonBottomPadding)
          }
          .onScrollGeometryChange(for: Bool.self) { geometry in
            let distanceFromBottom = geometry.contentSize.height
              - geometry.containerSize.height
              - geometry.contentOffset.y
            return distanceFromBottom > geometry.containerSize.height / 2
          } action: { _, newValue in
            self.showsScrollToBottomButton = newValue
          }
          .overlay(alignment: .bottomTrailing) {
            if self.showsScrollToBottomButton {
              Button {
                withAnimation {
                  proxy.scrollTo(Identifier.bottomAnchor, anchor: .bottom)
                }
              } label: {
                Image("down_button")
                  .resizable()
                  .scaledToFit()
                  .frame(width: Metric.downButtonSize, height: Metric.downButtonSize)
                  .background(
                    LinearGradient(
                      stops: [
                        Gradient.Stop(
                          color: .white,
                          location: Metric.softGradientStartLocation
                        ),
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
              }
              .buttonStyle(.plain)
              .padding(.trailing, Metric.horizontalPadding + Metric.downButtonTrailingPadding)
              .padding(.bottom, Metric.downButtonBottomPadding)
            }
          }
          .onChange(of: self.viewModel.messages.count) { _, _ in
            guard !self.showsScrollToBottomButton else { return }
            withAnimation {
              proxy.scrollTo(Identifier.bottomAnchor, anchor: .bottom)
            }
          }
        }
      }
      .overlay(alignment: .top) {
        if self.isQuestionExpanded {
          self.expandedQuestionView
            .padding(.horizontal, Metric.horizontalPadding)
            .padding(.top, Metric.horizontalPadding)
        }
      }

      ChatBottomView(
        messageText: self.$messageText,
        isFocused: self.$isMessageFieldFocused,
        currentQuestionCount: self.viewModel.voteCurrentCount,
        maxQuestionCount: self.viewModel.voteRequiredCount,
        onRequestQuestionTap: {
          Task {
            await self.viewModel.requestNewQuestion()
          }
        },
        onSendTap: {
          let text = self.messageText
          self.messageText = ""
          Task {
            await self.viewModel.sendMessage(text)
          }
        },
        isRequestQuestionDisabled:
          self.viewModel.currentQuestion?.questionOrder == self.viewModel.maxQuestions
      )
      .padding(.horizontal, Metric.horizontalPadding)
      .padding(.bottom, Metric.chatBottomBottomPadding)
      .disabled(self.viewModel.isMeetingEnded)
    }
    .contentShape(Rectangle())
    .onTapGesture {
      self.isMessageFieldFocused = false
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
    .task {
      await self.viewModel.enterChatRoom()
    }
    .onChange(of: self.viewModel.questionUpdateTrigger) { _, _ in
      withAnimation {
        self.isQuestionExpanded = true
      }
    }
    .onChange(of: self.scenePhase) { _, newPhase in
      guard newPhase == .active else { return }
      Task {
        await self.viewModel.reconnect()
      }
    }
    .onChange(of: self.messageText) { _, newValue in
      if newValue.count > ChatViewModel.messageMaxLength {
        self.messageText = String(newValue.prefix(ChatViewModel.messageMaxLength))
      }
    }
    .alert(
      "오류가 발생했습니다.",
      isPresented: Binding(
        get: { self.viewModel.errorMessage != nil },
        set: { isPresented in
          if !isPresented {
            self.viewModel.errorMessage = nil
          }
        }
      )
    ) {
      Button("확인", role: .cancel) {
        self.viewModel.errorMessage = nil
      }
    } message: {
      Text(self.viewModel.errorMessage ?? "")
    }
    .alert(
      "모임이 종료되었습니다.",
      isPresented: Binding(
        get: { self.viewModel.isMeetingEnded },
        set: { _ in }
      )
    ) {
      Button("확인", role: .cancel) {
        self.dismiss()
      }
    }
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
        Text(self.viewModel.chatRoom?.bookTitle ?? "")
          .caption1RegularStyle
          .foregroundStyle(.gray500)
      }

      Spacer(minLength: Metric.headerSpacerMinLength)

      HStack(spacing: Metric.badgeGroupSpacing) {
        HStack(spacing: Metric.badgeGroupSpacing) {
          Image("people_icon")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: Metric.peopleIconWidth, height: Metric.peopleIconHeight)
          Text("\(self.viewModel.appliedCount)/\(self.viewModel.chatRoom?.maxParticipants ?? 0)")
            .font(.caption1SemiBold)
            .tracking(Metric.captionTracking)
            .lineSpacing(Metric.captionLineSpacing)
        }
        .foregroundStyle(.gray600)
        .frame(width: Metric.badgeWidth, height: Metric.badgeHeight)
        .background(
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
          if let endsAt = self.viewModel.chatRoom?.endsAt, endsAt > Date.now {
            Text(timerInterval: Date.now...endsAt, countsDown: true)
              .font(.caption1SemiBold)
              .tracking(Metric.captionTracking)
              .lineSpacing(Metric.captionLineSpacing)
          } else {
            Text("00:00")
              .font(.caption1SemiBold)
              .tracking(Metric.captionTracking)
              .lineSpacing(Metric.captionLineSpacing)
          }
        }
        .foregroundStyle(.gray600)
        .frame(width: Metric.badgeWidth, height: Metric.badgeHeight)
        .background(
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
        LinearGradient(
          stops: [
            Gradient.Stop(color: .white, location: 0),
            Gradient.Stop(color: .white.opacity(0.4), location: 1.0)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
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

      Text(self.viewModel.currentQuestion?.content ?? "")
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
  ChatView(chatroomId: 3, meetingId: 10)
}
