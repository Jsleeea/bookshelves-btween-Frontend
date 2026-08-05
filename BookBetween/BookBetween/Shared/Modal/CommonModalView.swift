//
//  CommonModalView.swift
//  BookBetween
//

import SwiftUI

enum CommonModalIconGradientStyle {
  case green
  case error
}

enum CommonModalTitleStyle {
  case head2
  case head4
}

struct CommonModalView<Icon: View>: View {
  let title: String
  let description: String?
  let confirmTitle: String
  let cancelTitle: String?
  let titleColor: Color
  let titleStyle: CommonModalTitleStyle
  let confirmColor: Color
  let iconGradientStyle: CommonModalIconGradientStyle
  let modalHeight: CGFloat
  let icon: Icon
  var onCancel: () -> Void = {}
  var onConfirm: () -> Void = {}

  init(
    title: String,
    description: String? = nil,
    confirmTitle: String,
    cancelTitle: String? = nil,
    titleColor: Color = .gray800,
    titleStyle: CommonModalTitleStyle = .head2,
    confirmColor: Color = .green600,
    iconGradientStyle: CommonModalIconGradientStyle = .green,
    modalHeight: CGFloat = 220,
    onCancel: @escaping () -> Void = {},
    onConfirm: @escaping () -> Void = {},
    @ViewBuilder icon: () -> Icon
  ) {
    self.title = title
    self.description = description
    self.confirmTitle = confirmTitle
    self.cancelTitle = cancelTitle
    self.titleColor = titleColor
    self.titleStyle = titleStyle
    self.confirmColor = confirmColor
    self.iconGradientStyle = iconGradientStyle
    self.modalHeight = modalHeight
    self.onCancel = onCancel
    self.onConfirm = onConfirm
    self.icon = icon()
  }

  var body: some View {
    VStack(spacing: 0) {
      self.iconSection

      self.messageSection

      self.buttonSection
        .padding(.top, 24)
    }
    .padding(.horizontal, 30)
    .padding(.top, 44)
    .padding(.bottom, 20)
    .frame(width: 300, height: self.modalHeight, alignment: .center)
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
    ZStack {
      self.iconGradient

      self.icon
    }
    .frame(width: 100, height: 100)
  }

  private var iconGradient: EllipticalGradient {
    switch self.iconGradientStyle {
    case .green:
      EllipticalGradient(
        stops: [
          Gradient.Stop(
            color: Color(red: 0.8, green: 0.88, blue: 0.82).opacity(0.7),
            location: 0.51
          ),
          Gradient.Stop(color: .white.opacity(0), location: 1)
        ],
        center: UnitPoint(x: 0.5, y: 0.46)
      )

    case .error:
      EllipticalGradient(
        stops: [
          Gradient.Stop(color: Color.red500.opacity(0.5), location: 0),
          Gradient.Stop(color: .white.opacity(0), location: 1)
        ],
        center: UnitPoint(x: 0.5, y: 0.5)
      )
    }
  }

  private var messageSection: some View {
    VStack(spacing: 4) {
      titleText
        .foregroundStyle(self.titleColor)
        .multilineTextAlignment(.center)

      if let description = self.description {
        Text(description)
          .body2SemiBoldStyle
          .foregroundStyle(Color.gray500)
          .multilineTextAlignment(.center)
      }
    }
  }

  @ViewBuilder
  private var titleText: some View {
    switch titleStyle {
    case .head2:
      Text(title).head2Style
    case .head4:
      Text(title).head4Style
    }
  }

  private var buttonSection: some View {
    HStack(spacing: 12) {
      if let cancelTitle = self.cancelTitle {
        Button(action: self.onCancel) {
          Text(cancelTitle)
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

      Button(action: self.onConfirm) {
        Text(self.confirmTitle)
          .body1SemiBoldStyle
          .foregroundStyle(Color.beige100)
          .frame(maxWidth: .infinity, minHeight: 40)
          .background(self.confirmColor)
          .clipShape(RoundedRectangle(cornerRadius: 8))
      }
    }
    .padding(.bottom, 20)
  }
}
