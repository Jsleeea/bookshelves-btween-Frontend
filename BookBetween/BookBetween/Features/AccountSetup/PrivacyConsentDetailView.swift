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
        Text(self.content)
          .body1RegularStyle
          .foregroundStyle(Color.gray800)
          .fixedSize(horizontal: false, vertical: true)
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

#Preview {
  PrivacyConsentDetailView {}
}
