//
//  ErrorModalView.swift
//  BookBetween
//

import SwiftUI

struct ErrorModalView: View {
  let title: String
  var titleStyle: CommonModalTitleStyle = .head2
  var onConfirm: () -> Void = {}

  var body: some View {
    CommonModalView(
      title: self.title,
      confirmTitle: "확인",
      titleStyle: self.titleStyle,
      confirmColor: .red700,
      iconGradientStyle: .error,
      modalHeight: 220,
      onConfirm: self.onConfirm
    ) {
      Image("icon_exclamation_mark")
        .resizable()
        .scaledToFit()
        .frame(width: 56, height: 56)
    }
  }
}

#Preview {
  ErrorModalView(title: "모임이 종료되었습니다")
}
