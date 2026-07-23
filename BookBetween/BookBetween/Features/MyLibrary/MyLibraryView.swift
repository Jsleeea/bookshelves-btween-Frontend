import SwiftUI

struct MyLibraryView: View {
	@State private var viewModel = MyLibraryViewModel()

	var body: some View {
		VStack(spacing: 0) {
            HStack {
                Text("내 서재")
                    .head2Style
                    .foregroundStyle(Color.gray900)
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 11)

			tabSelector
                .padding(.bottom, 28)

			ScrollView(showsIndicators: false) {
				VStack(spacing: 16) {
					ForEach(viewModel.filteredRecords, id: \.id) { record in
						MyLibraryBookCardView(record: record)
					}
				}
				.padding(.bottom, 24)
			}
			.scrollBounceBehavior(.basedOnSize)
		}
		.toolbar(.hidden, for: .navigationBar)
	}

	// MARK: - Tab Selector

	private var tabSelector: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 8) {
				ForEach(MyLibraryTab.allCases, id: \.self) { tab in
					tabPill(for: tab)
				}
			}
            .padding(.top, 1)
            .padding(.horizontal, 30)
		}
	}

	private func tabPill(for tab: MyLibraryTab) -> some View {
		Button {
			viewModel.selectedTab = tab
		} label: {
			Text(tab.title)
				.caption1SemiBoldStyle
				.foregroundStyle(viewModel.selectedTab == tab ? Color.green600 : Color.green600)
                .padding(.horizontal, tab.horizontalPadding)
                .padding(.vertical, tab.verticalPadding)
				.background(viewModel.selectedTab == tab ? Color.green50 : Color.white)
				.clipShape(Capsule())
				.overlay {
					if viewModel.selectedTab != tab {
						Capsule()
							.stroke(Color.gray300, lineWidth: 1)
					}
				}
		}
	}
}

#Preview {
	NavigationStack {
		MyLibraryView()
	}
}
