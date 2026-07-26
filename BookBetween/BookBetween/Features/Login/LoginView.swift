//
//  LoginView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/9/26.
//

import SwiftUI

struct LoginView: View {
  @State private var viewModel: LoginViewModel

  init(viewModel: LoginViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    ZStack {
      LoginBackgroundView()

      LoginContentView(
        isLoading: viewModel.isLoading,
        onKakaoLogin: {
          Task {
            await viewModel.loginWithKakao()
          }
        }
      )
    }
    .alert(
      "로그인에 실패했습니다.",
      isPresented: Binding(
        get: { viewModel.errorMessage != nil },
        set: { isPresented in
          if !isPresented {
            viewModel.resetState()
          }
        }
      )
    ) {
      Button("확인") {
        viewModel.resetState()
      }
    } message: {
      Text(viewModel.errorMessage ?? "다시 시도해주세요.")
    }
  }
}

private struct LoginBackgroundView: View {
  var body: some View {
    ZStack {
      Color(red: 0.98, green: 0.98, blue: 0.98)
        .ignoresSafeArea()

      LinearGradient(
        stops: [
          Gradient.Stop(
            color: .white,
            location: 0.03
          ),
          Gradient.Stop(
            color: Color(red: 0.80, green: 0.88, blue: 0.82).opacity(0.8),
            location: 0.70
          )
        ],
        startPoint: UnitPoint(x: 0.52, y: 1.03),
        endPoint: UnitPoint(x: 0.52, y: 0.05)
      )
      .ignoresSafeArea()

      EllipticalGradient(
        stops: [
          Gradient.Stop(color: .white, location: 0.30),
          Gradient.Stop(color: .white.opacity(0), location: 1.00)
        ],
        center: UnitPoint(x: 0.5, y: 0.47)
      )
      .frame(width: 373, height: 376)
      .position(x: 197.5, y: 352)
    }
  }
}

private struct LoginContentView: View {
  let isLoading: Bool
  let onKakaoLogin: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      

      LoginLogoView()
        .padding(.top, 209)
        .padding(.bottom, 24)

      LoginTitleSectionView()
        .padding(.bottom, 32)

      LoginSocialButtonSectionView(
        isLoading: isLoading,
        onKakaoLogin: onKakaoLogin
      )

      Spacer()
    }
    .padding(.horizontal, 51)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

private struct LoginLogoView: View {
  var body: some View {
    Image("logo")
      .resizable()
      .scaledToFit()
      .frame(width: 266, height: 161)
  }
}

private struct LoginTitleSectionView: View {
  var body: some View {
    VStack(spacing: 10) {
        // 폰트 추가 후 수정 필요
      Text("책장을 넘어서,\n한 권으로 시작하는 모임")
        .pointText1Style
        .multilineTextAlignment(.center)
        .foregroundStyle(Color.green900)

      Text("책에만 집중할 수 있는 공간으로 들어가보세요")
        .caption1RegularStyle
        .foregroundStyle(Color.gray500)
    }
  }
}

private struct LoginSocialButtonSectionView: View {
  let isLoading: Bool
  let onKakaoLogin: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      KakaoLoginButton(
        isLoading: isLoading,
        action: onKakaoLogin
      )

      GoogleLoginButton()

      AppleLoginButton()
    }
  }
}

private struct KakaoLoginButton: View {
  let isLoading: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 8) {
        if isLoading {
          ProgressView()
            .tint(.black)
        } else {
          Image("kakao")
            .resizable()
            .scaledToFit()
            .frame(width: 18, height: 18)

          Text("카카오 로그인")
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.black)
        }
      }
      .frame(maxWidth: .infinity)
      .frame(height: 45)
      .background(Color(red: 1.0, green: 0.9, blue: 0.0))
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .disabled(isLoading)
  }
}

private struct GoogleLoginButton: View {
  var body: some View {
    Button {
    } label: {
      HStack(spacing: 11) {
        Image("google")
          .resizable()
          .scaledToFit()
          .frame(width: 19.5, height: 20)

        Text("Google 계정으로 로그인")
          .font(
            Font.custom("Roboto", size: 14)
              .weight(.medium)
          )
          .multilineTextAlignment(.center)
          .foregroundStyle(.black)
      }
      .frame(maxWidth: .infinity)
      .frame(height: 45)
      .background(.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
  }
}

private struct AppleLoginButton: View {
  var body: some View {
    Button {
    } label: {
      HStack(spacing: 8) {
        Image("apple")
          .resizable()
          .scaledToFit()
          .frame(width: 13, height: 14)

        Text("Apple로 로그인")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(.white)
      }
      .frame(maxWidth: .infinity)
      .frame(height: 45)
      .background(.black)
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
  }
}

#Preview {
  LoginView(
    viewModel: LoginViewModel(
      kakaoLoginService: KakaoLoginService(),
      authService: AuthService(
        baseURL: URL(string: "https://stub.bookbetween.local")!,
        provider: AuthStubProviderFactory.make(
          scenario: .pendingOnboarding
        )
      )
    )
  )
}
