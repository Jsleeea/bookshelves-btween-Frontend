//
//  SplashView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/14/26.
//

import SwiftUI

// MARK: - 스플래시 화면

struct SplashView: View {
  var body: some View {
    GeometryReader { geometry in

      ZStack {
        SplashBackgroundView()
            
        SplashLogoGlowView()
          .position(
            x: geometry.size.width / 2,
            y: geometry.size.height / 2
            )
              
        SplashLogoView()
          .position(
            x: geometry.size.width / 2,
            y: geometry.size.height / 2
            )
      }
    }
  }
}

// MARK: - 스플래시 배경

private struct SplashBackgroundView: View {
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

// MARK: - 스플래시 로고 빛 그라데이션

private struct SplashLogoGlowView: View {
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

// MARK: - 스플래시 로고

private struct SplashLogoView: View {
  var body: some View {
    Image("launchLogo")
      .resizable()
      .scaledToFit()
      .frame(width: 384, height: 384)
  }
}

#Preview {
  SplashView()
}
