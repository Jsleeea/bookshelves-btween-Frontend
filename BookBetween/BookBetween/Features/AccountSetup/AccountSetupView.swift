//
//  AccountSetupView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/10/26.
//

import SwiftUI

// MARK: - 계정 설정 화면

struct AccountSetupView: View {
  @State private var viewModel: AccountSetupViewModel
  let onStart: () -> Void

  init(
    viewModel: AccountSetupViewModel,
    onStart: @escaping () -> Void = {}
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onStart = onStart
  }

  var body: some View {
    ZStack {
      AccountSetupBackgroundView()

      AccountSetupContentView(
        viewModel: viewModel,
        onStart: onStart
      )
    }
  }
}

// MARK: - 배경 베이지색 + 양옆 나뭇잎 장식

private struct AccountSetupBackgroundView: View {
  var body: some View {
    ZStack {
      Color.beige100
        .ignoresSafeArea()

      AccountSetupLeafDecorationView()
    }
  }
}

// MARK: - 나뭇잎 장식

private struct AccountSetupLeafDecorationView: View {
  var body: some View {
    GeometryReader { _ in
      ZStack {
        Image("onboarding3LeafLeft")
          .resizable()
          .scaledToFit()
          .frame(width: 129, height: 143)
          .position(x: 64.5, y: 82.5)

        Image("onboarding3LeafRight")
          .resizable()
          .scaledToFit()
          .frame(width: 120, height: 142)
          .position(x: 342, y: 181)
      }
    }
    .ignoresSafeArea()
  }
}

// MARK: - 콘텐츠 영역

private struct AccountSetupContentView: View {
  let viewModel: AccountSetupViewModel
  let onStart: () -> Void

  @State private var generatedNickname: GeneratedNickname?
  @State private var isServiceTermsAgreed = false
  @State private var isPrivacyTermsAgreed = false
  @State private var isShowingServiceTerms = false
  @State private var isShowingPrivacyTerms = false
  @State private var selectedCategoryIDs: Set<Int> = []

  private var nickname: String {
    self.generatedNickname?.text ?? ""
  }

  private var agreedTermsIDs: [Int] {
    self.viewModel.agreedTermsIds(
      isServiceTermAgreed: self.isServiceTermsAgreed,
      isPrivacyTermAgreed: self.isPrivacyTermsAgreed
    )
  }

  private var isStartButtonEnabled: Bool {
    !self.nickname.isEmpty
      && self.viewModel.hasAgreedToAllRequiredTerms(
        agreedTermsIds: self.agreedTermsIDs
      )
      && !self.viewModel.isLoadingTerms
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      AccountSetupTitleSectionView()
        .padding(.top, 109)

      AccountSetupNicknameSectionView(
        nickname: self.nickname,
        refreshButtonAction: {
          self.generatedNickname = NicknameGenerator.generate(
            excluding: self.generatedNickname?.text
          )
        }
      )
        .padding(.top, 40)

      AccountSetupGenreSectionView(
        selectedCategoryIDs: self.$selectedCategoryIDs
      )
        .padding(.top, 32)

      Spacer(minLength: 48)

      AccountSetupTermsAgreementView(
        isServiceTermsAgreed: self.$isServiceTermsAgreed,
        isPrivacyTermsAgreed: self.$isPrivacyTermsAgreed,
        serviceTermsDetailButtonAction: {
          guard self.viewModel.serviceTerm != nil else { return }
          self.isShowingServiceTerms = true
        },
        privacyTermsDetailButtonAction: {
          guard self.viewModel.privacyTerm != nil else { return }
          self.isShowingPrivacyTerms = true
        }
      )

      AccountSetupStartButtonView(
        isEnabled: self.isStartButtonEnabled,
        isLoading: self.viewModel.isLoading
      ) {
        self.completeOnboarding()
      }
      .padding(.top, 13)
      .padding(.bottom, 16)
      .alert(
        "계정 설정을 완료하지 못했습니다.",
        isPresented: Binding(
          get: { self.viewModel.errorMessage != nil },
          set: { isPresented in
            if !isPresented {
              self.viewModel.resetState()
            }
          }
        )
      ) {
        Button("확인") {
          self.viewModel.resetState()
        }
      } message: {
        Text(self.viewModel.errorMessage ?? "다시 시도해주세요.")
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .task {
      await self.viewModel.fetchTerms()
    }
    .alert(
      "약관을 불러오지 못했습니다.",
      isPresented: Binding(
        get: { self.viewModel.termsErrorMessage != nil },
        set: { isPresented in
          if !isPresented {
            self.viewModel.resetTermsError()
          }
        }
      )
    ) {
      Button("다시 시도") {
        self.viewModel.resetTermsError()

        Task {
          await self.viewModel.fetchTerms()
        }
      }

      Button("취소", role: .cancel) {
        self.viewModel.resetTermsError()
      }
    } message: {
      Text(self.viewModel.termsErrorMessage ?? "다시 시도해주세요.")
    }
    .fullScreenCover(isPresented: self.$isShowingServiceTerms) {
      if let term = self.viewModel.serviceTerm {
        ServiceTermsDetailView(
          title: term.title,
          content: term.content
        ) {
          self.isServiceTermsAgreed = true
        }
      }
    }
    .fullScreenCover(isPresented: self.$isShowingPrivacyTerms) {
      if let term = self.viewModel.privacyTerm {
        PrivacyConsentDetailView(
          title: term.title,
          content: term.content
        ) {
          self.isPrivacyTermsAgreed = true
        }
      }
    }
  }

  private func completeOnboarding() {
    guard let generatedNickname = self.generatedNickname else {
      return
    }

    Task {
      await self.viewModel.completeOnboarding(
        nickname: generatedNickname,
        categoryIds: self.selectedCategoryIDs.sorted(),
        agreedTermsIds: self.agreedTermsIDs
      )

      guard self.viewModel.state == .success else {
        return
      }

      self.onStart()
    }
  }
}

// MARK: - 제목 영역

private struct AccountSetupTitleSectionView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("계정 설정")
        .head1Style
        .foregroundStyle(Color.gray800)

      Text("나중에 수정할 수 있어요")
        .body2SemiBoldStyle
        .foregroundStyle(Color.gray500)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.leading, 26)
  }
}

// MARK: - 닉네임 설정 영역

private struct AccountSetupNicknameSectionView: View {
  let nickname: String
  let refreshButtonAction: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("닉네임")
        .body1SemiBoldStyle
        .foregroundStyle(Color.gray800)
        .padding(.leading, 19)

      AccountSetupNicknameInputView(
        nickname: self.nickname,
        refreshButtonAction: self.refreshButtonAction
      )
        .padding(.top, 8)
        .padding(.horizontal, 19)

      Text("다른 사용자에게 표시되는 이름이에요.")
        .body2RegularStyle
        .foregroundStyle(Color.gray500)
        .padding(.top, 8)
        .padding(.leading, 29)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

// MARK: - 닉네임 입력 박스

private struct AccountSetupNicknameInputView: View {
  let nickname: String
  let refreshButtonAction: () -> Void

  var body: some View {
    HStack(spacing: 0) {
      Text(self.nickname.isEmpty ? "랜덤 닉네임을 생성해보세요" : self.nickname)
        .body2RegularStyle
        .foregroundStyle(self.nickname.isEmpty ? Color.gray600 : Color.gray800)

      Spacer()

      AccountSetupNicknameRefreshButton(action: self.refreshButtonAction)
    }
    .padding(.leading, 10)
    .padding(.trailing, 22.12)
    .frame(height: 46)
    .background(
      LinearGradient(
        stops: [
          Gradient.Stop(color: Color(red: 0.98, green: 0.98, blue: 0.99).opacity(0.4), location: 0.00),
          Gradient.Stop(color: .white, location: 0.72),
        ],
        startPoint: UnitPoint(x: 0.87, y: 0),
        endPoint: UnitPoint(x: 0.13, y: 1)
      )
    )
    .cornerRadius(12)
    .overlay {
      RoundedRectangle(cornerRadius: 12)
        .inset(by: 0.25)
        .stroke(Color.gray200, lineWidth: 0.5)
    }
  }
}

// MARK: - 닉네임 새로고침 버튼

private struct AccountSetupNicknameRefreshButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: self.action) {
      Image("refresh")
            .frame(width: 19.99, height: 20)
    }
  }
}

// MARK: - 장르 선택 영역

private struct AccountSetupGenreSectionView: View {
  @Binding var selectedCategoryIDs: Set<Int>

  private let genreRows: [[AccountSetupGenre]] = [
    [
      AccountSetupGenre(id: 1, name: "총류"),
      AccountSetupGenre(id: 2, name: "철학"),
      AccountSetupGenre(id: 3, name: "종교"),
      AccountSetupGenre(id: 4, name: "사회과학")
    ],
    [
      AccountSetupGenre(id: 5, name: "자연과학"),
      AccountSetupGenre(id: 6, name: "기술과학"),
      AccountSetupGenre(id: 7, name: "예술")
    ],
    [
      AccountSetupGenre(id: 8, name: "언어"),
      AccountSetupGenre(id: 9, name: "문학"),
      AccountSetupGenre(id: 10, name: "역사")
    ]
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("좋아하는 장르")
        .body1SemiBoldStyle
        .foregroundStyle(Color.gray800)

      VStack(alignment: .leading, spacing: 4) {
        ForEach(self.genreRows, id: \.self) { row in
          HStack(spacing: 8) {
            ForEach(row) { genre in
              GenreChipView(
                title: genre.name,
                isSelected: self.selectedCategoryIDs.contains(genre.id)
              ) {
                self.toggleGenre(genre)
              }
            }
          }
        }
      }
      .padding(.top, 12)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.leading, 27)

  }

  private func toggleGenre(_ genre: AccountSetupGenre) {
    if self.selectedCategoryIDs.contains(genre.id) {
      self.selectedCategoryIDs.remove(genre.id)
    } else {
      self.selectedCategoryIDs.insert(genre.id)
    }
  }
}

private struct AccountSetupGenre: Identifiable, Hashable {
  let id: Int
  let name: String
}

// MARK: - 약관 동의 영역

private struct AccountSetupTermsAgreementView: View {
  @Binding var isServiceTermsAgreed: Bool
  @Binding var isPrivacyTermsAgreed: Bool

  let serviceTermsDetailButtonAction: () -> Void
  let privacyTermsDetailButtonAction: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      AccountSetupTermsAgreementRow(
        title: "서비스 이용약관 동의",
        isAgreed: self.$isServiceTermsAgreed,
        detailButtonAction: self.serviceTermsDetailButtonAction
      )

      Divider()
        .foregroundStyle(Color.gray200)

      AccountSetupTermsAgreementRow(
        title: "개인정보 수집 및 이용 동의",
        isAgreed: self.$isPrivacyTermsAgreed,
        detailButtonAction: self.privacyTermsDetailButtonAction
      )
      Divider()
        .foregroundStyle(Color.gray200)

    }
    .padding(.horizontal, 29)
  }
}

private struct AccountSetupTermsAgreementRow: View {
  let title: String
  @Binding var isAgreed: Bool
  let detailButtonAction: () -> Void

  var body: some View {
    HStack(spacing: 12) {
      Button {
        self.isAgreed.toggle()
      } label: {
        AccountSetupAgreementCheckboxView(isChecked: self.isAgreed)
          .frame(width: 22, height: 22)
      }

      HStack(spacing: 12) {
        Text("[필수]")
          .body2SemiBoldStyle
          .foregroundStyle(Color.green700)

        Text(self.title)
          .body2SemiBoldStyle
          .foregroundStyle(Color.gray800)
      }

      Spacer()

      Button(action: self.detailButtonAction) {
        Image("icon_chevron_right_gray")
          .resizable()
          .scaledToFit()
          .frame(width: 9, height: 18)
      }
    }
    .frame(height: 22)
  }
}

// MARK: - 약관 동의 체크박스

private struct AccountSetupAgreementCheckboxView: View {
  let isChecked: Bool

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 1)
            .fill(self.isChecked ? Color.green600 : Color.clear)
        .frame(width: 22, height: 22)
        .overlay {
          RoundedRectangle(cornerRadius: 1)
            .inset(by: 0.5)
            .stroke(
                self.isChecked ? Color.green600 : Color.gray300,
              lineWidth: 1
            )
        }

      if self.isChecked {
        Image("check")
          .foregroundStyle(Color.white)
          .frame(width: 15, height: 9)

      }
    }
  }
}

// MARK: - 시작하기 버튼

private struct AccountSetupStartButtonView: View {
  let isEnabled: Bool
  let isLoading: Bool
  let action: () -> Void

  var body: some View {
    Button(action: self.action) {
      Group {
        if self.isLoading {
          ProgressView()
            .tint(Color.white)
        } else {
          Text("시작하기")
            .head3Style
            .foregroundStyle(Color.white)
        }
      }
      .frame(maxWidth: .infinity)
      .frame(height: 53)
      .background(self.isEnabled ? Color.green600 : Color.gray300)
      .cornerRadius(12)
    }
    .disabled(!self.isEnabled || self.isLoading)
    .padding(.horizontal, 29)
  }
}

#Preview {
  AccountSetupView(
    viewModel: AccountSetupViewModel(
      onboardingService: PreviewOnboardingService()
    )
  )
}
