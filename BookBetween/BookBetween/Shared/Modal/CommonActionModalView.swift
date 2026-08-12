//
//  CommonActionModalView.swift
//  BookBetween
//

import SwiftUI

enum CommonActionModalType {
  case withdraw
  case recovery
  case logout
  case report

  var iconName: String {
    switch self {
    case .withdraw, .logout:
      "icon_door"
    case .recovery:
      "icon_key"
    case .report:
      "icon_siren"
    }
  }

  var iconSize: CGSize {
    switch self {
    case .withdraw, .logout:
      CGSize(width: 45, height: 45)
    case .recovery:
      CGSize(width: 44, height: 50)
    case .report:
      CGSize(width: 45, height: 54)
    }
  }

  var title: String {
    switch self {
    case .withdraw:
      "탈퇴하시겠습니까?"
    case .recovery:
      "계정을 복구하시겠습니까?"
    case .logout:
      "로그아웃 하시겠습니까?"
    case .report:
      "채팅방을 신고하시겠습니까?"
    }
  }

  var description: String {
    switch self {
    case .withdraw:
      "탈퇴하기 클릭 후 30일이 지나면\n계정 복구가 불가능합니다"
    case .recovery:
      "탈퇴 처리 중인 계정입니다\n복구 시 기존 계정으로 로그인됩니다"
    case .logout:
      "해당 기기에서 로그아웃 됩니다"
    case .report:
      "신고된 내용은 관리자 검토 후 운영 정책에\n따라 처리됩니다"
    }
  }

  var titleColor: Color {
    .gray800
  }

  var confirmTitle: String {
    switch self {
    case .withdraw:
      "탈퇴하기"
    case .recovery:
      "복구하기"
    case .logout:
      "로그아웃"
    case .report:
      "신고하기"
    }
  }

  var cancelTitle: String {
    "취소하기"
  }

  var confirmColor: Color {
    self == .report ? .red700 : .green600
  }

  var iconGradient: EllipticalGradient {
    switch self {
    case .report:
      EllipticalGradient(
        stops: [
          Gradient.Stop(color: Color.red500.opacity(0.3), location: 0),
          Gradient.Stop(color: .white.opacity(0), location: 1)
        ],
        center: .center
      )
    case .withdraw, .recovery, .logout:
      EllipticalGradient(
        stops: [
          Gradient.Stop(
            color: Color(red: 0.8, green: 0.88, blue: 0.82).opacity(0.5),
            location: 0.51
          ),
          Gradient.Stop(color: .white.opacity(0), location: 1)
        ],
        center: UnitPoint(x: 0.5, y: 0.46)
      )
    }
  }
}

struct CommonActionModalView: View {
  let type: CommonActionModalType
  var onCancel: () -> Void = {}
  var onConfirm: () -> Void = {}

  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        Image(self.type.iconName)
          .resizable()
          .scaledToFit()
          .frame(
            width: self.type.iconSize.width,
            height: self.type.iconSize.height
          )
      }
      .frame(width: 100, height: 100)
      .background(self.type.iconGradient)
      .clipShape(Circle())

      Text(self.type.title)
        .head2Style
        .foregroundStyle(self.type.titleColor)
        .multilineTextAlignment(.center)
        .padding(.bottom, 4)

      Text(self.type.description)
        .font(.body2SemiBold)
        .foregroundStyle(Color.gray500)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)

      HStack(spacing: 12) {
        Button(action: self.onCancel) {
          Text(self.type.cancelTitle)
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

        Button(action: self.onConfirm) {
          Text(self.type.confirmTitle)
            .body1SemiBoldStyle
            .foregroundStyle(Color.beige100)
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(self.type.confirmColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
      }
      .padding(.top, 11)
    }
    .padding(20)
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
}

#Preview("Action Modals") {
  VStack(spacing: 20) {
    //CommonActionModalView(type: .withdraw)
    CommonActionModalView(type: .recovery)
    CommonActionModalView(type: .logout)
    CommonActionModalView(type: .report)
  }
  .padding()
  .background(Color.gray100)
}
