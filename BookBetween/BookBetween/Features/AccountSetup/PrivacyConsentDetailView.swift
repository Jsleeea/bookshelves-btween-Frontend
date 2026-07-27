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

  let onAgree: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      PrivacyConsentNavigationBar {
        self.dismiss()
      }

      Divider()
        .foregroundStyle(Color.gray200)

      ScrollView {
        LazyVStack(alignment: .leading, spacing: 40) {
          Text("책장사이는 서비스 제공에 필요한 최소한의 개인정보를 수집·이용합니다.")
            .body1RegularStyle
            .foregroundStyle(Color.gray800)
            .fixedSize(horizontal: false, vertical: true)

          PrivacyConsentSection(
            title: "1. 수집·이용 목적",
            items: [
              "카카오·구글 소셜 로그인 및 회원 식별",
              "회원가입, 계정 관리 및 계정 복구",
              "도서 검색, 독서 기록 및 내 서재 기능 제공",
              "독서 모임 생성·검색·참여 기능 제공",
              "익명 실시간 채팅 및 AI 대화 요약 제공",
              "서비스 알림 및 신고·부정 이용 방지"
            ]
          )

          PrivacyConsentSection(
            title: "2. 수집 항목",
            items: [
              "소셜 로그인 제공자",
              "소셜 계정 고유 식별값",
              "이메일 주소: 소셜 로그인 제공자로부터 실제로 제공받는 경우",
              "서비스 내 랜덤 닉네임",
              "관심 장르"
            ],
            notice: "서비스 이용 과정에서 아래 정보가 추가로 생성·저장될 수 있습니다."
          )

          PrivacyConsentSection(
            title: "3. 보유 및 이용 기간",
            items: [
              "회원탈퇴 신청일로부터 30일 동안 계정을 탈퇴 유예 상태로 보관합니다. 유예기간 내 다시 로그인할 경우 기존 계정을 복구할 수 있으며, 30일이 지나면 회원탈퇴가 최종 완료됩니다. 탈퇴 완료 후 개인정보는 관계 법령에 따라 보관할 의무가 있는 정보를 제외하고 파기합니다."
            ],
            showsItemBullets: false
          )

          PrivacyConsentSection(
            title: "4. 동의 거부 권리 및 불이익",
            items: [
              "이용자는 개인정보 수집·이용 동의를 거부할 수 있습니다. 다만, 필수 개인정보 수집·이용에 동의하지 않을 경우 회원가입 및 책장사이 서비스 이용이 제한됩니다."
            ],
            showsItemBullets: false
          )
        }
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

      Text("개인정보 수집 및 이용 동의")
        .head1Style
        .foregroundStyle(Color.gray800)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 24)
    .padding(.bottom, 22)
    .background(Color.beige100)
  }
}

// MARK: - 개인정보 수집 및 이용 동의 항목 영역

private struct PrivacyConsentSection: View {
  let title: String
  let description: String?
  let items: [String]
  let notice: String?
  let showsItemBullets: Bool

  init(
    title: String,
    description: String? = nil,
    items: [String] = [],
    notice: String? = nil,
    showsItemBullets: Bool = true
  ) {
    self.title = title
    self.description = description
    self.items = items
    self.notice = notice
    self.showsItemBullets = showsItemBullets
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(self.title)
        .head2Style
        .foregroundStyle(Color.green700)

      if let description = self.description {
        Text(description)
          .body1SemiBoldStyle
          .foregroundStyle(Color.gray800)
          .fixedSize(horizontal: false, vertical: true)
      }

      if !self.items.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
          ForEach(self.items, id: \.self) { item in
            if self.showsItemBullets {
              // 글머리표와 본문을 분리해 줄바꿈된 문장을 본문 시작 위치에 맞춤
              HStack(alignment: .top, spacing: 4) {
                Text("  · ")
                  .body1RegularStyle

                Text(item)
                  .body1RegularStyle
                  .fixedSize(horizontal: false, vertical: true)
              }
              .foregroundStyle(Color.gray800)
            } else {
              Text(item)
                .body1RegularStyle
                .foregroundStyle(Color.gray800)
                .fixedSize(horizontal: false, vertical: true)
            }
          }
        }
      }

      if let notice = self.notice {
        // 안내문도 글머리표와 본문을 분리해 여러 줄의 시작 위치를 통일
        HStack(alignment: .top, spacing: 4) {
          Text("·")
            .body2RegularStyle

          Text(notice)
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
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  PrivacyConsentDetailView {}
}
