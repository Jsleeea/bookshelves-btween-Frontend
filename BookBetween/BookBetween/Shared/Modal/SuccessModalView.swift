//
//  SuccessModalView.swift
//  BookBetween
//

import SwiftUI

struct SuccessModalView: View {
  let title: String
  var onConfirm: () -> Void = {}

  var body: some View {
    CommonModalView(
      title: self.title,
      confirmTitle: "확인",
      confirmColor: .green600,
      modalHeight: 220,
      onConfirm: self.onConfirm
    ) {
      Image("icon_check_mark")
        .resizable()
        .scaledToFit()
        .frame(width: 56, height: 56)
    }
  }
}

#Preview {
  SuccessModalView(title: "모임을 생성했습니다")
}
