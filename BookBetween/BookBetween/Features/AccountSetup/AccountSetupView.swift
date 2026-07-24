//
//  AccountSetupView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/10/26.
//

import SwiftUI

// MARK: - 계정 설정 화면

struct AccountSetupView: View {
  let onStart: () -> Void

  init(onStart: @escaping () -> Void = {}) {
    self.onStart = onStart
  }

  var body: some View {
    ZStack {
      AccountSetupBackgroundView()

      AccountSetupContentView(onStart: onStart)
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
        Image("accountSetupleaf")
          .resizable()
          .scaledToFit()
          .frame(width: 123.45, height: 138.25)
          .position(x: 65, y: 95)

        Image("accountSetupLeafRight")
          .resizable()
          .scaledToFit()
          .frame(width: 122.96, height: 137.71)
          .position(x: 344.30, y: 210)
      }
    }
    .ignoresSafeArea()
  }
}

// MARK: - 콘텐츠 영역

private struct AccountSetupContentView: View {
  let onStart: () -> Void

  @State private var generatedNickname: GeneratedNickname?
  @State private var isAgreed = false

  private var nickname: String {
    self.generatedNickname?.text ?? ""
  }

  private var isStartButtonEnabled: Bool {
    !self.nickname.isEmpty && self.isAgreed
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      AccountSetupTitleSectionView()
        .padding(.top, 126)

      AccountSetupNicknameSectionView(
        nickname: self.nickname,
        refreshButtonAction: {
          self.generatedNickname = NicknameGenerator.generate(
            excluding: self.generatedNickname?.text
          )
        }
      )
        .padding(.top, 36)

      AccountSetupGenreSectionView()
        .padding(.top, 32)

      AccountSetupTermsAgreementView(
        isAgreed: self.$isAgreed
      )
        .padding(.top, 48)

      AccountSetupStartButtonView(
        isEnabled: self.isStartButtonEnabled
      ) {
        self.onStart()
      }
      .padding(.top, 12)

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

// MARK: - 제목 영역

private struct AccountSetupTitleSectionView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("계정 설정")
        .head1Style
        .foregroundStyle(Color.gray800)

      Text("나중에 수정할 수 있어요")
        .caption1SemiBoldStyle
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
        .padding(.leading, 30)

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
        .padding(.leading, 30)
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
        .body1RegularStyle
        .foregroundStyle(self.nickname.isEmpty ? Color.gray500 : Color.gray800)

      Spacer()

      AccountSetupNicknameRefreshButton(action: self.refreshButtonAction)
    }
    .padding(.leading, 18)
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
    .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
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
  @State private var selectedGenres: Set<String> = []

  private let genreRows: [[String]] = [
    ["총류", "철학", "종교", "사회과학"],
    ["자연과학", "기술과학", "예술"],
    ["언어", "문학", "역사"]
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("좋아하는 장르")
        .body1SemiBoldStyle
        .foregroundStyle(Color.gray800)

      VStack(alignment: .leading, spacing: 4) {
        ForEach(self.genreRows, id: \.self) { row in
          HStack(spacing: 8) {
            ForEach(row, id: \.self) { genre in
              GenreChipView(
                title: genre,
                isSelected: self.selectedGenres.contains(genre)
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

  private func toggleGenre(_ genre: String) {
    if self.selectedGenres.contains(genre) {
      self.selectedGenres.remove(genre)
    } else {
      self.selectedGenres.insert(genre)
    }
  }
}

// MARK: - 약관 동의 영역

private struct AccountSetupTermsAgreementView: View {
  @Binding var isAgreed: Bool

  var body: some View {
    HStack(spacing: 0) {
      Button {
        self.isAgreed.toggle()
      } label: {
        AccountSetupAgreementCheckboxView(isChecked: self.isAgreed)
      }

      Text("이용약관 및 개인정보 처리방침에 동의합니다.")
        .caption1SemiBoldStyle
        .foregroundStyle(Color.gray500)
        .padding(.leading, 10)

      Spacer()

      Button {
      } label: {
        Image("icon_chevron_right_gray500")
          .resizable()
          .scaledToFit()
          .frame(width: 6, height: 12)
      }
      .buttonStyle(.plain)
    }
    .padding(.horizontal, 16)
    .frame(height: 41)
    .background(Color.white)
    .cornerRadius(12)
    .overlay {
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.gray300, lineWidth: 0.5)
    }
    .padding(.horizontal, 28.5)
  }
}

// MARK: - 약관 동의 체크박스

private struct AccountSetupAgreementCheckboxView: View {
  let isChecked: Bool

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 1)
            .fill(self.isChecked ? Color.green600 : Color.clear)
        .frame(width: 15, height: 15)
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
          .frame(width: 10, height: 6)

      }
    }
  }
}

// MARK: - 시작하기 버튼

private struct AccountSetupStartButtonView: View {
  let isEnabled: Bool
  let action: () -> Void

  var body: some View {
    Button(action: self.action) {
      Text("시작하기")
        .head3Style
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)
        .frame(height: 53)
        .background(self.isEnabled ? Color.green600 : Color.gray300)
        .cornerRadius(12)
    }
    .disabled(!self.isEnabled)
    .padding(.horizontal, 29)
  }
}

#Preview {
  AccountSetupView()
}
