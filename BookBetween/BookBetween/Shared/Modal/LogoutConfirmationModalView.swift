//
//  LogoutConfirmationModalView.swift
//  BookBetween
//

import SwiftUI

struct LogoutConfirmationModalView: View {
  var onCancel: () -> Void = {}
  var onConfirm: () -> Void = {}

  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 0) {
        self.iconSection

        Text("해당 기기에서 로그아웃 됩니다")
          .body2SemiBoldStyle
          .foregroundStyle(Color.gray500)
          .padding(.top, 16)
      }

      HStack(spacing: 12) {
        self.cancelButton
        self.confirmButton
      }
      .padding(.top, 19)
    }
    .padding(.horizontal, 30)
    .padding(.vertical, 20)
    .frame(width: 300)
    .background(Color.beige100)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(
      color: Color(red: 0.17, green: 0.16, blue: 0.16).opacity(0.16),
      radius: 24,
      x: 0,
      y: 20
    )
    .overlay {
      RoundedRectangle(cornerRadius: 12)
        .inset(by: 0.5)
        .stroke(.white, lineWidth: 1)
    }
  }

  private var iconSection: some View {
    VStack(spacing: 25.5) {
      Image("door")
        .resizable()
        .scaledToFit()
        .frame(width: 45, height: 45)
        .padding(.top, 27.5)
        .background(alignment: .top) {
          EllipticalGradient(
            stops: [
              Gradient.Stop(color: Color(red: 0.8, green: 0.88, blue: 0.82).opacity(0.7), location: 0.51),
              Gradient.Stop(color: .white.opacity(0), location: 1)
            ],
            center: UnitPoint(x: 0.5, y: 0.46)
          )
          .frame(width: 100, height: 100)
          .clipShape(Circle())
        }

      Text("로그아웃 하시겠습니까?")
        .head2Style
        .foregroundStyle(Color.gray800)
    }
  }

  private var cancelButton: some View {
    Button(action: self.onCancel) {
      Text("취소하기")
        .body1SemiBoldStyle
        .foregroundStyle(Color.gray800)
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(Color.beige100)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray800, lineWidth: 1)
        }
    }
  }

  private var confirmButton: some View {
    Button(action: self.onConfirm) {
      Text("로그아웃")
        .body1SemiBoldStyle
        .foregroundStyle(Color.beige100)
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(Color.green700)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
  }
}

#Preview {
  LogoutConfirmationModalView()
}
