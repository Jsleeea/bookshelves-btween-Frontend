//
//  ChatBottomView.swift
//  BookBetween
//
//  Created by 한지민 on 7/4/26.
//

import SwiftUI
import UIKit

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

    static let messageInputSpacing: CGFloat = 9
    static let textFieldVerticalPadding: CGFloat = 9.5
    static let sendButtonSize: CGFloat = 35
    static let sendButtonVerticalPadding: CGFloat = 2
    static let sendButtonDisabledOpacity: CGFloat = 0.4
    static let messageInputLeadingPadding: CGFloat = 16
    static let messageInputTrailingPadding: CGFloat = 4
    static let textEditorMinHeight: CGFloat = 40
    static let textEditorMaxHeight: CGFloat = 120
    static let textEditorPlaceholderTopPadding: CGFloat = 13
  }

  // MARK: - Properties

  @Binding var messageText: String
  @State private var measuredContentHeight: CGFloat = Metric.textEditorMinHeight
  @Binding var isFocused: Bool
  let currentQuestionCount: Int
  let maxQuestionCount: Int
  let onRequestQuestionTap: () -> Void
  let onSendTap: () -> Void
  let isRequestQuestionDisabled: Bool

  private var isMessageOverLimit: Bool {
    self.messageText.utf16.count > ChatViewModel.messageMaxLength
  }

  // MARK: - Body

  var body: some View {
    VStack(spacing: Metric.containerSpacing) {
      if !self.isFocused {
        self.questionRequestRow
      }
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
    HStack(alignment: .bottom, spacing: Metric.messageInputSpacing) {
      ZStack(alignment: .topLeading) {
        if self.messageText.isEmpty && !self.isFocused {
          Text("메시지 입력")
            .font(.caption1SemiBold)
            .tracking(Metric.smallCaptionTracking) // 자간 -0.3%
            .lineSpacing(Metric.smallCaptionLineSpacing) // 행간 20pt (12pt 기준 +8)
            .padding(.top, Metric.textEditorPlaceholderTopPadding)
            .foregroundStyle(.gray200)
            .allowsHitTesting(false)
        }

        ChatTextEditor(
          text: self.$messageText,
          isFocused: self.$isFocused,
          measuredHeight: self.$measuredContentHeight,
          minHeight: Metric.textEditorMinHeight,
          maxHeight: Metric.textEditorMaxHeight,
          lineSpacing: Metric.smallCaptionLineSpacing,
          tracking: Metric.smallCaptionTracking
        )
      }
      .frame(
        height: min(
          max(self.measuredContentHeight, Metric.textEditorMinHeight),
          Metric.textEditorMaxHeight
        ),
        alignment: .center
      )
      .frame(maxWidth: .infinity)

      Button(action: self.onSendTap) {
        Image("direct_icon")
          .resizable()
          .scaledToFit()
          .frame(width: Metric.sendButtonSize, height: Metric.sendButtonSize)
      }
      .padding(.vertical, Metric.sendButtonVerticalPadding)
      .disabled(self.isMessageOverLimit)
      .opacity(self.isMessageOverLimit ? Metric.sendButtonDisabledOpacity : 1)
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

// MARK: - Chat Text Editor

private struct ChatTextEditor: UIViewRepresentable {
  @Binding var text: String
  @Binding var isFocused: Bool
  @Binding var measuredHeight: CGFloat
  let minHeight: CGFloat
  let maxHeight: CGFloat
  let lineSpacing: CGFloat
  let tracking: CGFloat

  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  func makeUIView(context: Context) -> StableCaretTextView {
    let textView = StableCaretTextView()
    textView.delegate = context.coordinator
    textView.backgroundColor = .clear
    textView.contentInset = .zero
    textView.textContainer.lineFragmentPadding = 0
    textView.textContainer.lineBreakMode = .byCharWrapping
    textView.textContainer.maximumNumberOfLines = 0
    textView.keyboardDismissMode = .interactive
    textView.adjustsFontForContentSizeCategory = false
    textView.isScrollEnabled = false
    context.coordinator.configure(textView)

    // 최초 레이아웃 시점에는 bounds.width가 0이라 높이를 잴 수 없다.
    // 폭이 확정된 뒤(그리고 이후 폭이 바뀔 때마다) 다시 재도록 연결한다.
    textView.onLayout = { [weak coordinator = context.coordinator] textView in
      coordinator?.updateMeasuredHeight(of: textView, deferred: true)
    }
    return textView
  }

  func updateUIView(_ textView: StableCaretTextView, context: Context) {
    context.coordinator.parent = self

    if textView.text != self.text {
      textView.text = self.text
      context.coordinator.applyTextStyle(to: textView)
    }

    context.coordinator.updateFocus(of: textView)
    context.coordinator.updateMeasuredHeight(of: textView, deferred: true)
  }

  func sizeThatFits(
    _ proposal: ProposedViewSize,
    uiView: StableCaretTextView,
    context: Context
  ) -> CGSize? {
    let width = proposal.width ?? uiView.bounds.width
    let height = min(max(self.measuredHeight, self.minHeight), self.maxHeight)
    return CGSize(width: width, height: height)
  }

  final class Coordinator: NSObject, UITextViewDelegate {
    var parent: ChatTextEditor
    private var heightUpdateGeneration = 0
    private var hasOverflowHighlight = false

    private var font: UIFont {
      UIFont(name: "Pretendard-SemiBold", size: 12)
        ?? .systemFont(ofSize: 12, weight: .semibold)
    }

    private var paragraphStyle: NSParagraphStyle {
      let style = NSMutableParagraphStyle()
      style.lineSpacing = self.parent.lineSpacing
      return style
    }

    private var baseAttributes: [NSAttributedString.Key: Any] {
      [
        .font: self.font,
        .kern: self.parent.tracking,
        .paragraphStyle: self.paragraphStyle,
        .foregroundColor: UIColor(Color.gray200)
      ]
    }

    init(parent: ChatTextEditor) {
      self.parent = parent
    }

    func configure(_ textView: StableCaretTextView) {
      let verticalInset = max(0, (self.parent.minHeight - self.font.lineHeight) / 2)
      textView.font = self.font
      textView.caretHeight = self.font.lineHeight
      textView.textContainerInset = UIEdgeInsets(
        top: verticalInset,
        left: 0,
        bottom: verticalInset,
        right: 0
      )
      textView.typingAttributes = self.baseAttributes
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
      self.parent.isFocused = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
      self.parent.isFocused = false
    }

    func textViewDidChange(_ textView: UITextView) {
      if textView.markedTextRange == nil {
        self.updateOverflowHighlight(in: textView)
      }

      self.updateMeasuredHeight(of: textView, deferred: false)
      self.parent.text = textView.text
    }

    func updateFocus(of textView: UITextView) {
      if self.parent.isFocused {
        if !textView.isFirstResponder {
          textView.becomeFirstResponder()
        }
      } else if textView.isFirstResponder {
        textView.resignFirstResponder()
      }
    }

    func applyTextStyle(to textView: UITextView) {
      let selectedRange = textView.selectedRange
      let fullRange = NSRange(location: 0, length: textView.text.utf16.count)

      textView.textStorage.setAttributes(self.baseAttributes, range: fullRange)

      if fullRange.length > ChatViewModel.messageMaxLength {
        let overflowRange = NSRange(
          location: ChatViewModel.messageMaxLength,
          length: fullRange.length - ChatViewModel.messageMaxLength
        )
        textView.textStorage.addAttributes(
          [
            .backgroundColor: UIColor(Color.red50),
            .foregroundColor: UIColor(Color.red700)
          ],
          range: overflowRange
        )
      }

      self.hasOverflowHighlight = fullRange.length > ChatViewModel.messageMaxLength
      textView.selectedRange = selectedRange
      textView.typingAttributes = self.baseAttributes
    }

    private func updateOverflowHighlight(in textView: UITextView) {
      let fullRange = NSRange(location: 0, length: textView.text.utf16.count)
      let hasOverflow = fullRange.length > ChatViewModel.messageMaxLength
      guard hasOverflow || self.hasOverflowHighlight else { return }

      let selectedRange = textView.selectedRange
      textView.textStorage.beginEditing()
      textView.textStorage.removeAttribute(.backgroundColor, range: fullRange)
      textView.textStorage.addAttribute(
        .foregroundColor,
        value: UIColor(Color.gray200),
        range: fullRange
      )

      if hasOverflow {
        let overflowRange = NSRange(
          location: ChatViewModel.messageMaxLength,
          length: fullRange.length - ChatViewModel.messageMaxLength
        )
        textView.textStorage.addAttributes(
          [
            .backgroundColor: UIColor(Color.red50),
            .foregroundColor: UIColor(Color.red700)
          ],
          range: overflowRange
        )
      }

      textView.textStorage.endEditing()
      self.hasOverflowHighlight = hasOverflow
      textView.selectedRange = selectedRange
      textView.typingAttributes = self.baseAttributes
    }

    func updateMeasuredHeight(of textView: UITextView, deferred: Bool) {
      let width = textView.bounds.width
      guard width > 0 else { return }

      // sizeThatFits는 textContainerInset과 개행으로 생긴 마지막 빈 줄까지 포함해
      // 계산하므로, layoutManager로 직접 재는 것보다 정확하다.
      let contentHeight = ceil(
        textView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
      )
      let height = min(
        max(contentHeight, self.parent.minHeight),
        self.parent.maxHeight
      )
      let shouldScroll = contentHeight > self.parent.maxHeight
      if textView.isScrollEnabled != shouldScroll {
        textView.isScrollEnabled = shouldScroll
      }

      guard abs(self.parent.measuredHeight - height) > 0.5 else { return }
      self.heightUpdateGeneration += 1
      let generation = self.heightUpdateGeneration

      let applyHeight = { [weak self] in
        guard let self, self.heightUpdateGeneration == generation else { return }
        self.parent.measuredHeight = height
      }

      if deferred {
        DispatchQueue.main.async(execute: applyHeight)
      } else {
        applyHeight()
      }
    }
  }
}

private final class StableCaretTextView: UITextView {
  var caretHeight: CGFloat = 0
  /// 레이아웃으로 폭이 확정된 뒤 높이를 다시 재기 위한 콜백.
  var onLayout: ((StableCaretTextView) -> Void)?

  override func caretRect(for position: UITextPosition) -> CGRect {
    var rect = super.caretRect(for: position)
    guard self.caretHeight > 0, rect.height > self.caretHeight else { return rect }

    // lineSpacing은 글자 아래쪽에 붙으므로, 캐럿을 라인 프래그먼트 위쪽에 맞춰야
    // 실제 글자와 정렬된다. (가운데 정렬하면 lineSpacing의 절반만큼 내려간다)
    rect.size.height = self.caretHeight
    return rect
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if !self.isScrollEnabled && self.contentOffset != .zero {
      self.contentOffset = .zero
    }

    self.onLayout?(self)
  }
}

#Preview {
  @Previewable @State var isFocused = false

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
