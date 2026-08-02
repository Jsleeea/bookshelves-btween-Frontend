//
//  PrivacyConsentDetailView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/27/26.
//

import SwiftUI

// MARK: - 개인정보 수집 및 이용 동의 상세 화면

struct PrivacyConsentDetailView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var hasReachedBottom = false

  let title: String
  let content: String
  let onAgree: () -> Void

  init(
    title: String = "개인정보 수집 및 이용 동의",
    content: String = "약관 내용을 불러오는 중입니다.",
    onAgree: @escaping () -> Void
  ) {
    self.title = title
    self.content = content
    self.onAgree = onAgree
  }

  var body: some View {
    VStack(spacing: 0) {
      PrivacyConsentNavigationBar(title: self.title) {
        self.dismiss()
      }

      Divider()
        .foregroundStyle(Color.gray200)

      ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
          ForEach(
            Array(self.content.components(separatedBy: "\n").enumerated()),
            id: \.offset
          ) { _, line in
            PrivacyTermsContentLineView(line: line)
          }
        }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 24)
          .padding(.top, 16)
          .padding(.bottom, 40)
          .background(Color.beige100)
      }
      .onScrollGeometryChange(for: Bool.self) { geometry in
        guard geometry.contentSize.height > 0 else { return false }

        return geometry.visibleRect.maxY >= geometry.contentSize.height - 1
      } action: { _, hasReachedBottom in
        if hasReachedBottom {
          self.hasReachedBottom = true
        }
      }
    }
    .background(Color.white.ignoresSafeArea())
    .safeAreaInset(edge: .bottom, spacing: 0) {
      Button {
        self.onAgree()
        self.dismiss()
      } label: {
        Text("동의합니다")
          .body1SemiBoldStyle
          .foregroundStyle(Color.beige100)
          .frame(maxWidth: .infinity)
          .frame(height: 53)
          .background(
            self.hasReachedBottom ? Color.green600 : Color.gray400
          )
          .clipShape(RoundedRectangle(cornerRadius: 12))
      }
      .disabled(!self.hasReachedBottom)
      .padding(.horizontal, 29)
      .padding(.bottom, 16)
      .background(Color.beige100)
    }
  }
}

// MARK: - 상단 내비게이션 영역

private struct PrivacyConsentNavigationBar: View {
  let title: String
  let backButtonAction: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Button(action: self.backButtonAction) {
        Image("icon_chevron_left")
          .resizable()
          .scaledToFit()
          .frame(width: 12, height: 24)
          .frame(width: 44, height: 44, alignment: .leading)
      }

      Text(self.title)
        .head1Style
        .foregroundStyle(Color.gray800)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 24)
    .padding(.bottom, 22)
    .background(Color.beige100)
  }
}

// MARK: - 개인정보 약관 본문

private struct PrivacyTermsContentLineView: View {
  let line: String

  private var trimmedLine: String {
    self.line.trimmingCharacters(in: .whitespaces)
  }

  private var isSectionTitle: Bool {
    guard let separatorIndex = self.trimmedLine.firstIndex(of: ".") else {
      return false
    }

    return Int(self.trimmedLine[..<separatorIndex]) != nil
  }

  private var bulletContent: String? {
    guard self.trimmedLine.hasPrefix("-") else { return nil }

    return self.trimmedLine.dropFirst()
      .trimmingCharacters(in: .whitespaces)
  }

  private var isAdditionalInformationNotice: Bool {
    self.trimmedLine.hasPrefix("서비스 이용 과정에서")
  }

  @ViewBuilder
  var body: some View {
    if self.trimmedLine.isEmpty {
      Color.clear
        .frame(height: 16)
    } else if self.isSectionTitle {
      Text(self.trimmedLine)
        .head2Style
        .foregroundStyle(Color.green700)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 8)
        .padding(.bottom, 12)
    } else if let bulletContent = self.bulletContent {
      HStack(alignment: .top, spacing: 6) {
        Text("·")
          .body1RegularStyle

        Text(bulletContent)
          .body1RegularStyle
          .fixedSize(horizontal: false, vertical: true)
      }
      .foregroundStyle(Color.gray800)
      .padding(.bottom, 10)
    } else if self.isAdditionalInformationNotice {
      HStack(alignment: .top, spacing: 6) {
        Text("·")
          .body2RegularStyle

        Text(self.trimmedLine)
          .body2RegularStyle
          .fixedSize(horizontal: false, vertical: true)
      }
      .foregroundStyle(Color.green800)
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        Color(red: 0.91, green: 0.94, blue: 0.92),
        in: RoundedRectangle(cornerRadius: 8)
      )
      .padding(.vertical, 4)
    } else {
      Text(self.trimmedLine)
        .body1RegularStyle
        .foregroundStyle(Color.gray800)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, 10)
    }
  }
}

#Preview {
  PrivacyConsentDetailView {}
}
