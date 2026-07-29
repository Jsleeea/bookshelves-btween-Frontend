import SwiftUI

struct MyLibraryView: View {
	@State private var viewModel = MyLibraryViewModel()
    private let bookService: any BookServiceProtocol

    init(bookService: any BookServiceProtocol) {
        self.bookService = bookService
    }

	var body: some View {
		VStack(spacing: 0) {
            HStack {
                Text("내 서재")
                    .head2Style
                    .foregroundStyle(Color.gray900)
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 6)

			tabSelector

			ScrollView(showsIndicators: false) {
				VStack(spacing: 16) {
					ForEach(viewModel.filteredRecords, id: \.id) { record in
						MyLibraryBookCardView(
                            record: record,
                            bookService: bookService,
                            onRecordSaved: viewModel.updateRecord
                        )
					}
				}
                .padding(.top, 14)
				.padding(.bottom, 100)
			}
			.scrollBounceBehavior(.basedOnSize)
		}
		.toolbar(.hidden, for: .navigationBar)
	}

	// MARK: - Tab Selector

	private var tabSelector: some View {
		HStack(spacing: 8) {
			ForEach(MyLibraryTab.allCases, id: \.self) { tab in
				tabPill(for: tab)
			}
			Spacer()
		}
        .padding(.top, 6)
        .padding(.bottom, 14)
        .padding(.horizontal, 30)
	}

	private func tabPill(for tab: MyLibraryTab) -> some View {
		Button {
			viewModel.selectedTab = tab
		} label: {
			Text(tab.title)
				.body2SemiBoldStyle
				.foregroundStyle(viewModel.selectedTab == tab ? Color.green600 : Color.green600)
                .frame(width: 70, height: 30)
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
		MyLibraryView(bookService: BookService.stubbed())
	}
}
