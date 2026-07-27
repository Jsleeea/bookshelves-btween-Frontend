//
//  ServiceTermsDetailView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/27/26.
//

import SwiftUI

// MARK: - 서비스 이용약관 상세 화면

struct ServiceTermsDetailView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var hasReachedBottom = false

  let onAgree: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      ServiceTermsNavigationBar {
        self.dismiss()
      }

      Divider()
        .foregroundStyle(Color.gray200)

      ScrollView {
        LazyVStack(alignment: .leading, spacing: 40) {
          ServiceTermsSection(
            title: "제1조 목적",
            items: [
              "본 약관은 책장사이가 제공하는 독서 기록, 내 서재, 독서 모임, 익명 채팅 및 AI 대화 요약 서비스의 이용 조건과 절차를 규정합니다."
            ],
            showsItemNumbers: false
          )

          ServiceTermsSection(
            title: "제2조 회원가입 및 계정",
            items: [
              "이용자는 카카오 또는 구글 소셜 로그인을 통해 가입할 수 있습니다.",
              "이용자는 타인의 계정을 이용하거나 자신의 계정을 제3자에게 양도·공유해서는 안 됩니다.",
              "소셜 로그인 제공자의 정책 또는 계정 상태에 따라 로그인이 제한될 수 있습니다."
            ]
          )

          ServiceTermsSection(
            title: "제3조 서비스 제공",
            description: "책장사이는 다음 서비스를 제공합니다.",
            items: [
              "도서 검색 및 독서 기록 관리",
              "내 서재 및 독서 통계",
              "독서 모임 생성·검색·참여",
              "익명 실시간 채팅",
              "AI 발제문 및 대화 요약",
              "모임 및 서비스 관련 알림"
            ]
          )

          ServiceTermsSection(
            title: "제4조 이용자의 의무",
            description: "이용자는 다음 행위를 해서는 안 됩니다.",
            items: [
              "타인을 사칭하거나 허위 정보를 등록하는 행위",
              "욕설, 혐오, 음란, 불법 또는 타인의 권리를 침해하는 내용을 작성하는 행위",
              "채팅 도배, 광고 또는 서비스 운영을 방해하는 행위",
              "다른 이용자의 개인정보를 수집하거나 외부에 공개하는 행위",
              "비정상적인 방법으로 서비스에 접근하거나 기술적 보호조치를 우회하는 행위"
            ]
          )

          ServiceTermsSection(
            title: "제5조 신고 및 이용 제한",
            items: [
              "운영정책을 위반한 이용자는 신고될 수 있습니다. 위반 정도에 따라 콘텐츠 삭제, 채팅 참여 제한, 일시 정지 또는 영구 이용 제한 조치가 적용될 수 있습니다."
            ],
            showsItemNumbers: false
          )

          ServiceTermsSection(
            title: "제6조 이용자 콘텐츠",
            items: [
              "이용자가 작성한 독서 기록과 채팅 내용에 대한 권리는 원칙적으로 해당 이용자에게 있습니다. 다만, 서비스 제공·운영 및 AI 대화 요약 생성에 필요한 범위에서 해당 콘텐츠가 저장·처리될 수 있습니다."
            ],
            showsItemNumbers: false
          )

          ServiceTermsSection(
            title: "제7조 모임 운영",
            items: [
              "모임은 정해진 모집 기간, 정원 및 진행시간에 따라 운영됩니다.",
              "모집 마감 시 최소 참여 인원을 충족하지 못한 모임은 자동 취소될 수 있습니다.",
              "이용자는 참여한 모임의 운영 규칙과 채팅 운영정책을 준수해야 합니다.",
              "정당한 사유 없이 모임에 참여하지 않은 경우 노쇼 기록이 생성될 수 있습니다."
            ]
          )

          ServiceTermsSection(
            title: "제8조 회원탈퇴",
            items: [
              "이용자는 계정 설정에서 회원탈퇴를 신청할 수 있습니다.",
              "탈퇴 신청 후 30일 동안 탈퇴 유예 상태가 유지됩니다.",
              "유예기간 내 다시 로그인하면 기존 계정을 복구할 수 있습니다.",
              "30일이 지나면 회원탈퇴가 최종 완료되며, 관계 법령에 따른 보존 대상 정보를 제외한 개인정보가 파기됩니다."
            ]
          )

          ServiceTermsSection(
            title: "제9조 서비스 변경 및 중단",
            items: [
              "서비스 점검, 장애 또는 운영상 필요한 사유가 있는 경우 서비스의 일부 또는 전부가 일시적으로 제한될 수 있습니다."
            ],
            showsItemNumbers: false
          )

          ServiceTermsSection(
            title: "제10조 약관 변경",
            items: [
              "약관이 변경되는 경우 적용일과 주요 변경 내용을 서비스 내 공지 등을 통해 안내합니다."
            ],
            showsItemNumbers: false
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

private struct ServiceTermsNavigationBar: View {
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

      Text("서비스 이용약관")
        .head1Style
        .foregroundStyle(Color.gray800)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 24)
    .padding(.bottom, 22)
    .background(Color.beige100)
  }
}

// MARK: - 서비스 이용약관 조항 영역

private struct ServiceTermsSection: View {
  let title: String
  let description: String?
  let items: [String]
  let showsItemNumbers: Bool

  init(
    title: String,
    description: String? = nil,
    items: [String] = [],
    showsItemNumbers: Bool = true
  ) {
    self.title = title
    self.description = description
    self.items = items
    self.showsItemNumbers = showsItemNumbers
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
          ForEach(Array(self.items.enumerated()), id: \.offset) { index, item in
            // 번호와 본문을 분리해 줄바꿈된 문장을 본문 시작 위치에 맞춤
            HStack(alignment: .top, spacing: 6) {
              if self.showsItemNumbers {
                Text("\(index + 1).")
                  .body1RegularStyle
              }

              Text(item)
                .body1RegularStyle
                .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(Color.gray800)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  ServiceTermsDetailView {}
}
