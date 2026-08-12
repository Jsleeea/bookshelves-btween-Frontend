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
        GeometryReader { geometry in
            let idleHeight = max(geometry.size.height - 145, 520)

            ZStack(alignment: .top) {
                if viewModel.filteredRecords.isEmpty {
                    SearchIdleView(height: idleHeight, customTitle: "저장된 도서가 없어요")
                        .padding(.horizontal, 19)
                        .offset(y: 145)
                        .transition(.opacity)
                }

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
                        Color.clear.frame(height: idleHeight)
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
                        .contentMargins(.top, 6, for: .scrollContent)
                        .contentMargins(.bottom, 84, for: .scrollContent)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.filteredRecords.isEmpty)
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
        .alert("도서 목록을 불러오지 못했습니다", isPresented: Binding(
            get: { viewModel.fetchError != nil },
            set: { if !$0 { viewModel.fetchError = nil } }
        )) {
            Button("확인", role: .cancel) { viewModel.fetchError = nil }
        } message: {
            Text(viewModel.fetchError ?? "")
        }
        .alert("삭제에 실패했습니다", isPresented: Binding(
            get: { viewModel.deleteError != nil },
            set: { if !$0 { viewModel.deleteError = nil } }
        )) {
            Button("확인", role: .cancel) { viewModel.deleteError = nil }
        } message: {
            Text(viewModel.deleteError ?? "")
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
