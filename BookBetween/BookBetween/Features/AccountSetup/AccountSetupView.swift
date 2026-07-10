//
//  AccountSetupView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/10/26.
//

import SwiftUI

// MARK: - 계정 설정 화면

struct AccountSetupView: View {
  var body: some View {
    ZStack {
      AccountSetupBackgroundView()

      AccountSetupContentView()
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
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      AccountSetupTitleSectionView()
        .padding(.top, 126)

      Spacer()
    }
    .padding(.horizontal, 28)
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
  }
}

#Preview {
  AccountSetupView()
}
