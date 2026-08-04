//
//  AccountActionModalView.swift
//  BookBetween
//

import SwiftUI

struct AccountActionModalView: View {
  let title: String
  let description: String
  let confirmTitle: String
  var onCancel: () -> Void = {}
  var onConfirm: () -> Void = {}

  var body: some View {
    CommonModalView(
      title: self.title,
      description: self.description,
      confirmTitle: self.confirmTitle,
      cancelTitle: "취소하기",
      confirmColor: .green700,
      modalHeight: 250,
      onCancel: self.onCancel,
      onConfirm: self.onConfirm
    ) {
      Image("door")
        .resizable()
        .scaledToFit()
        .frame(width: 56, height: 56)
    }
  }
}

#Preview("Logout") {
  AccountActionModalView(
    title: "로그아웃 하시겠습니까?",
    description: "해당 기기에서 로그아웃 됩니다",
    confirmTitle: "로그아웃"
  )
}

#Preview("Withdrawal") {
  AccountActionModalView(
    title: "탈퇴하시겠습니까?",
    description: "탈퇴하기 클릭 후 30일이 지나면\n계정 복구가 불가능합니다",
    confirmTitle: "탈퇴하기"
  )
}
