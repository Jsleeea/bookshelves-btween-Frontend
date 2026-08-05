import SwiftUI

private struct BookClubErrorOverlay: ViewModifier {
    @Binding var showFetchError: Bool
    @Binding var showSummaryPending: Bool
    let fetchErrorTitle: String
    let summaryPendingTitle: String

    func body(content: Content) -> some View {
        content.overlay {
            if showFetchError || showSummaryPending {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    if showFetchError {
                        ErrorModalView(title: fetchErrorTitle, titleStyle: .head4) {
                            showFetchError = false
                        }
                    } else {
                        ErrorModalView(title: summaryPendingTitle, titleStyle: .head4) {
                            showSummaryPending = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func bookClubErrorOverlay(
        showFetchError: Binding<Bool>,
        showSummaryPending: Binding<Bool>,
        fetchErrorTitle: String = "데이터를 불러오지 못했습니다",
        summaryPendingTitle: String = "요약이 완료되지 않았습니다"
    ) -> some View {
        modifier(BookClubErrorOverlay(
            showFetchError: showFetchError,
            showSummaryPending: showSummaryPending,
            fetchErrorTitle: fetchErrorTitle,
            summaryPendingTitle: summaryPendingTitle
        ))
    }
}

// MARK: - Preview

private struct BookClubErrorOverlayPreview: View {
    @State private var showFetchError = false
    @State private var showSummaryPending = false

    var body: some View {
        ZStack {
            Color.beige100.ignoresSafeArea()

            VStack(spacing: 20) {
                Button("데이터 불러오기 실패 모달") {
                    showFetchError = true
                }
                Button("요약 미완료 모달") {
                    showSummaryPending = true
                }
            }
        }
        .bookClubErrorOverlay(
            showFetchError: $showFetchError,
            showSummaryPending: $showSummaryPending
        )
    }
}

#Preview {
    BookClubErrorOverlayPreview()
}
