import SwiftUI

struct MyLibraryView: View {
	@State private var viewModel: MyLibraryViewModel
    private let bookService: any BookServiceProtocol

    init(bookService: any BookServiceProtocol) {
        self.bookService = bookService
        _viewModel = State(initialValue: MyLibraryViewModel(bookService: bookService))
    }

	var body: some View {
		VStack(spacing: 0) {
            HStack {
                Text("내 서재")
                    .head2Style
                    .foregroundStyle(Color.gray900)
                Spacer()
            }
            .padding(.top, 8)
            .padding(.horizontal, 30)
            .padding(.bottom, 6)

			tabSelector

			List {
				ForEach(viewModel.filteredRecords, id: \.id) { record in
					MyLibraryBookCardView(
						record: record,
						bookService: bookService,
						onRecordSaved: { saved in
                            viewModel.updateRecord(saved)
                            Task { await viewModel.fetchRecords() }
                        }
					)
					.listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
					.listRowSeparator(.hidden)
					.listRowBackground(Color.clear)
					.swipeActions(edge: .trailing, allowsFullSwipe: true) {
						Button(role: .destructive) {
							Task { await viewModel.deleteRecord(record) }
						} label: {
							Label("삭제", systemImage: "trash")
						}
					}
				}
			}
			.listStyle(.plain)
			.scrollContentBackground(.hidden)
			.refreshable {
                await viewModel.fetchRecords()
            }
			.scrollBounceBehavior(.basedOnSize)
			.contentMargins(.top, 6, for: .scrollContent)
			.contentMargins(.bottom, 84, for: .scrollContent)
		}
		.toolbar(.hidden, for: .navigationBar)
        .task(id: viewModel.selectedTab) {
            await viewModel.fetchRecords()
        }
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
				.foregroundStyle(Color.green600)
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
