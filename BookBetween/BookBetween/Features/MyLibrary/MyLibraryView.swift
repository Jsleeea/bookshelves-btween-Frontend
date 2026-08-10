import SwiftUI

struct MyLibraryView: View {
	@State private var viewModel: MyLibraryViewModel
    @State private var selectedRecord: UserBookRecord?
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

            if viewModel.filteredRecords.isEmpty {
                emptyStateView
                    .frame(height: 522)
            } else {
                List {
                    ForEach(viewModel.filteredRecords, id: \.id) { record in
                        Button {
                            selectedRecord = record
                        } label: {
                            MyLibraryBookCardView(record: record)
                        }
                        .buttonStyle(.plain)
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
		}
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
		.toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: Binding(
            get: { selectedRecord != nil },
            set: { if !$0 { selectedRecord = nil } }
        )) {
            if let record = selectedRecord {
                BookRecordDetailView(
                    record: record,
                    service: bookService,
                    loadsRemoteDetail: true,
                    onRecordSaved: { saved in
                        viewModel.updateRecord(saved)
                        Task { await viewModel.fetchRecords() }
                    }
                )
            }
        }
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

    // MARK: - Empty State

    private var emptyStateView: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                RadialGradient(
                    stops: [
                        Gradient.Stop(color: Color.green01.opacity(0.4), location: 0.2982),
                        Gradient.Stop(color: Color.green01.opacity(0.0), location: 0.7019)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: w * 0.5951
                )

                Image("leaf_left")
                    .resizable().scaledToFit()
                    .frame(width: 100, height: 108)
                    .position(x: 30, y: h * 0.13)

                Image("leaf_right")
                    .resizable().scaledToFit()
                    .frame(width: 100, height: 108)
                    .position(x: w - 30, y: h * 0.22)

                Image("search_logo")
                    .resizable().scaledToFit()
                    .frame(width: 152, height: 131)
                    .position(x: w / 2, y: h * 0.46)

                Text("저장된 도서가 없어요")
                    .pointText5Style
                    .foregroundStyle(Color.green900)
                    .position(x: w / 2, y: h * 0.67)
            }
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
	NavigationStack {
		MyLibraryView(bookService: BookService.stubbed())
	}
}
