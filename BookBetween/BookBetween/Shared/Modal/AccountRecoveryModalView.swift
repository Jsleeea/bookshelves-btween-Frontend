//
//  AccountRecoveryModalView.swift
//  BookBetween
//

import SwiftUI

struct AccountRecoveryModalView: View {
  var onCancel: () -> Void = {}
  var onConfirm: () -> Void = {}

  var body: some View {
    CommonModalView(
      title: "계정을 복구하시겠습니까?",
      description: "탈퇴 처리 중인 계정입니다\n복구 시 기존 계정으로 로그인됩니다",
      confirmTitle: "복구하기",
      cancelTitle: "취소하기",
      titleColor: .green900,
      confirmColor: .green700,
      modalHeight: 250,
      onCancel: self.onCancel,
      onConfirm: self.onConfirm
    ) {
      Image("icon_key")
        .resizable()
        .scaledToFit()
        .frame(width: 56, height: 56)
    }
  }
}

#Preview {
  AccountRecoveryModalView()
}
