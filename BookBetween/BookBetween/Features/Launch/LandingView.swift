//
//  LandingView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/14/26.
//

import SwiftUI

// MARK: - 랜딩 화면

struct LandingView: View {
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        LandingBackgroundView()

        LandingLogoGroupView()
          .position(
            x: geometry.size.width / 2,
            y: geometry.size.height / 2
          )

        VStack(spacing: 105) {
          LandingTitleSectionView()

          LandingStartGuideView()
        }
          .padding(.top, 576)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      }
    }
    .ignoresSafeArea()
  }
}

// MARK: - 랜딩 배경

private struct LandingBackgroundView: View {
  var body: some View {
    LinearGradient(
      stops: [
        Gradient.Stop(color: Color.green50, location: 0.06),
        Gradient.Stop(color: Color.blue100, location: 1.00)
      ],
      startPoint: UnitPoint(x: 0.5, y: 0),
      endPoint: UnitPoint(x: 0.5, y: 1)
    )
    .ignoresSafeArea()
  }
}

// MARK: - 랜딩 로고 빛 그라데이션

private struct LandingLogoGlowView: View {
  var body: some View {
    EllipticalGradient(
      stops: [
        Gradient.Stop(color: .white, location: 0.27),
        Gradient.Stop(color: .white.opacity(0), location: 0.82)
      ],
      center: UnitPoint(x: 0.52, y: 0.5)
    )
    .frame(width: 631, height: 631)
  }
}

// MARK: - 랜딩 로고 그룹

private struct LandingLogoGroupView: View {
  var body: some View {
    ZStack {
      LandingLogoGlowView()

      LandingLogoView()
    }
  }
}

// MARK: - 랜딩 로고

private struct LandingLogoView: View {
  var body: some View {
    Image("launchLogo")
      .resizable()
      .scaledToFit()
      .frame(width: 384, height: 384)
  }
}

// MARK: - 랜딩 타이틀

private struct LandingTitleSectionView: View {
  var body: some View {
    VStack(spacing: 12) {
      Text("책으로 이어지는 대화")
        .pointText5Style
        .foregroundStyle(Color.green900)

      Text("책장사이")
        .pointText1Style
        .foregroundStyle(Color.green900)
    }
  }
}

// MARK: - 랜딩 시작 안내

private struct LandingStartGuideView: View {
  var body: some View {
    VStack(spacing: 4) {
      ProgressView()

      Text("화면을 터치하여 시작하세요")
        .body2RegularStyle
        .foregroundStyle(Color.gray500)
    }
  }
}

#Preview {
  LandingView()
}
