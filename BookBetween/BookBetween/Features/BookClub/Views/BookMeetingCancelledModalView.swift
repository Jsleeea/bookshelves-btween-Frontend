import SwiftUI

struct BookMeetingCancelledModalView: View {
    let subtitle: String?
    var onConfirm: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            topIcon

            VStack(spacing: 4) {
                Text("독서모임이 취소되었습니다")
                    .head3Style
                    .foregroundStyle(Color.gray800)
                    .multilineTextAlignment(.center)

                if let subtitle {
                    Text(subtitle)
                        .caption1SemiBoldStyle
                        .foregroundStyle(Color.gray500)
                        .multilineTextAlignment(.center)
                }
            }
            
            confirmButton
                .padding(.top, 12)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .frame(width: 300, height: subtitle != nil ? 243 : 223)
        .background { modalBackground }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay { borderOverlay }
        .shadow(color: Color.gray900.opacity(0.16), radius: 12, x: 0, y: 20)
    }

    // MARK: - topIcon

    private var topIcon: some View {
        Image("icon_exclamation_mark_style")
            .resizable()
            .scaledToFit()
            .frame(width: 110, height: 110)
    }

    // MARK: - confirmButton

    private var confirmButton: some View {
        Button(action: onConfirm) {
            Text("확인")
                .body1SemiBoldStyle
                .foregroundStyle(Color.white)
                .frame(width: 240, height: 40)
                .background(Color.red700)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Common Styling

    private var modalBackground: some View {
        LinearGradient(
            stops: [
                .init(color: .white, location: 0.8367),
                .init(color: Color.white.opacity(0.2), location: 1.5517)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(
                LinearGradient(
                    stops: [
                        .init(color: Color.white.opacity(0.2), location: 0.2499),
                        .init(color: .white, location: 0.8197)
                    ],
                    startPoint: UnitPoint(x: 0.967, y: 0.321),
                    endPoint: UnitPoint(x: 0.033, y: 0.679)
                ),
                lineWidth: 1.5
            )
    }
}

#Preview("모임 취소 (서브타이틀 있음)") {
    BookMeetingCancelledModalView(
        subtitle: "혼모노 | 7/15 (수) · 18:30 | 2/6",
        onConfirm: {}
    )
    .padding(.horizontal, 24)
}

#Preview("모임 취소 (서브타이틀 없음)") {
    BookMeetingCancelledModalView(
        subtitle: nil,
        onConfirm: {}
    )
    .padding(.horizontal, 24)
}
