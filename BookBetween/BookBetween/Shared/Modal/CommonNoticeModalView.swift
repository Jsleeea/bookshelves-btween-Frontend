//
//  CommonNoticeModalView.swift
//  BookBetween
//

import SwiftUI

// MARK: - 알림 모달 유형

enum CommonNoticeModalType {
  case success
  case error
  case report

  // MARK: - 유형별 설정

  var iconName: String {
    switch self {
    case .success:
      "icon_check_mark"
    case .error:
      "icon_exclamation_mark"
    case .report:
      "icon_siren"
    }
  }

  var confirmColor: Color {
    switch self {
    case .success:
      .green600
    case .error, .report:
      .red700
    }
  }

  var iconSize: CGSize {
    switch self {
    case .success:
      CGSize(width: 50, height: 44)
    case .error:
      CGSize(width: 50, height: 50)
    case .report:
      CGSize(width: 45, height: 54)
    }
  }

  var iconGradient: EllipticalGradient {
    switch self {
    case .success:
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
    case .error, .report:
      EllipticalGradient(
        stops: [
          Gradient.Stop(color: Color.red500.opacity(0.3), location: 0),
          Gradient.Stop(color: .white.opacity(0), location: 1)
        ],
        center: UnitPoint(x: 0.5, y: 0.5)
      )
    }
  }
}

// MARK: - 공통 알림 모달

struct CommonNoticeModalView: View {
  // MARK: - 속성

  let type: CommonNoticeModalType
  let title: String
  var onConfirm: () -> Void = {}

  // MARK: - 화면 구성

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

      Text(self.title)
        .head3Style
        .foregroundStyle(Color.gray800)
        .multilineTextAlignment(.center)

      Spacer()

      Button(action: self.onConfirm) {
        Text("확인")
          .body1SemiBoldStyle
          .foregroundStyle(Color.beige100)
          .frame(width: 220, height: 38)
          .background(self.type.confirmColor)
          .clipShape(RoundedRectangle(cornerRadius: 12))
      }
    }
    .padding(20)
    .frame(width: 300, height: 220)
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

#Preview("Notice Modals") {
  VStack(spacing: 20) {
    CommonNoticeModalView(type: .success, title: "저장되었습니다")
    CommonNoticeModalView(type: .error, title: "종료된 모임입니다")
    CommonNoticeModalView(type: .report, title: "신고되었습니다")
  }
  .padding()
  .background(Color.gray200)
}
