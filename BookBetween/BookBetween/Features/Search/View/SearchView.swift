//
//  SearchView.swift
//  BookBetween
//
//  Created by 이준성 on 6/25/26.
//

import SwiftUI

@MainActor
struct SearchView: View {
    @State private var viewModel: SearchViewModel
    @State private var presentedActionMenuItemID: UUID?
    @FocusState private var isSearchFocused: Bool
    private let meetingService: (any MeetingServiceProtocol)?
    private let onMeetingCreated: (() -> Void)?

    init(meetingService: (any MeetingServiceProtocol)? = nil) {
        _viewModel = State(
            initialValue: SearchViewModel(service: BookService.stubbed())
        )
        self.meetingService = meetingService
        self.onMeetingCreated = nil
    }

    init(
        viewModel: SearchViewModel,
        meetingService: (any MeetingServiceProtocol)? = nil,
        onMeetingCreated: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: viewModel)
        self.meetingService = meetingService
        self.onMeetingCreated = onMeetingCreated
    }

    var body: some View {
        GeometryReader { geometry in
            let idleHeight = max(geometry.size.height - 145, 520)

            ZStack(alignment: .top) {
                if !viewModel.isSearching && !viewModel.hasSearched {
                    SearchIdleView(height: idleHeight, mode: .idle)
                        .padding(.horizontal, 19)
                        .offset(y: 145)
                        .transition(.opacity)
                } else if viewModel.hasSearched && viewModel.searchResults.isEmpty {
                    SearchIdleView(height: idleHeight, mode: .emptyResult)
                        .padding(.horizontal, 19)
                        .offset(y: 145)
                        .transition(.opacity)
                }

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 16) {
                        TitleView
                        SearchInputSectionView
                    }
                    .padding(.horizontal, 19)

                    ScrollView(showsIndicators: false) {
                        SearchResultSectionView(
                            idleHeight: idleHeight
                        )
                        .padding(.horizontal, 19)
                        .padding(.bottom, 80)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .refreshable {
                        isSearchFocused = false
                        await viewModel.refresh()
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isSearchFocused = false
                }
            }
            .animation(.easeInOut(duration: 0.2), value: searchResultPhase)
            .padding(.top, 8)
        }
        .navigationDestination(for: SearchRoute.self) { route in
            switch route {
            case .createMeeting(let book):
                BookMeetingCreateView(book: book, service: meetingService, onMeetingCreated: onMeetingCreated)
            case .bookDetail(let item):
                BookRecordDetailView(
                    book: item.book,
                    isSaveable: item.isSaveable,
                    service: viewModel.bookService,
                    loadsRemoteDetail: true,
                    startsInEditingMode: true
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .task {
            await viewModel.loadRecentSearches()
        }
        .alert(
            "도서 정보를 불러오지 못했습니다.",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("확인", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private enum SearchResultPhase: Equatable {
        case idle
        case searching
        case empty
        case results
    }

    private var searchResultPhase: SearchResultPhase {
        if viewModel.isSearching {
            return .searching
        } else if !viewModel.hasSearched {
            return .idle
        } else if viewModel.searchResults.isEmpty {
            return .empty
        } else {
            return .results
        }
    }

    // MARK: 도서검색 TITLE
    private var TitleView: some View {
        HStack {
            Text("도서 검색")
                .head2Style
                .foregroundStyle(Color.gray900)
            Spacer()
        }
        .padding(.leading, 11) // 11 + 19 = 30
    }
    
    // MARK: - 검색 바
    private var SearchInputSectionView: some View {
        VStack(spacing: 0) {
            SearchBarView

            if isSearchFocused && !viewModel.recentKeywords.isEmpty {
                Divider()
                    .background(.gray200)
                    .padding(.horizontal, 20)
                RecentSearchListView
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray200, lineWidth: 0.5)
        )
    }
    
    private var SearchBarView: some View {
        HStack(spacing: 10) {
            Image(.iconMagnifyingglass)
                .foregroundStyle(Color.gray600)

            TextField("검색어를 입력하세요", text: $viewModel.searchText)
                .font(.body1Regular)
                .foregroundStyle(Color.gray800)
                .focused($isSearchFocused)
                .onSubmit {
                    isSearchFocused = false
                    Task {
                        await viewModel.submitSearch()
                    }
                }
        }
        .frame(height: 46)
        .padding(.horizontal, 11)
    }
    
    private var RecentSearchListView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("최근 검색 도서")
                .body2SemiBoldStyle
                .foregroundStyle(Color.gray600)
                .padding(.top, 11)

            VStack(spacing: 7) {
                ForEach(viewModel.recentKeywords, id: \.self) { keyword in
                    RecentKeywordRow(
                        keyword: keyword,
                        onSelect: {
                            viewModel.selectRecentKeyword(keyword)
                            isSearchFocused = false
                            Task {
                                await viewModel.submitSearch()
                            }
                        },
                        onDelete: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.removeRecentKeyword(keyword)
                            }
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 13)
    }
    
    private func SearchResultSectionView(idleHeight: CGFloat) -> some View {
        LazyVStack(spacing: 12) {
            if viewModel.isSearching {
                ProgressView()
                    .padding(.top, 24)
                    .transition(.opacity)
            } else if !viewModel.hasSearched {
                Color.clear
                    .frame(height: idleHeight)
                    .transition(.opacity)
            } else if viewModel.hasSearched && viewModel.searchResults.isEmpty {
                Color.clear
                    .frame(height: idleHeight)
                    .transition(.opacity)
            } else {
                ForEach(viewModel.searchResults, id: \.listID) { item in
                    SearchBookResultCardView(
                        item: item,
                        service: viewModel.bookService,
                        meetingService: meetingService,
                        isActionMenuPresented: actionMenuBinding(for: item)
                    )
                        .zIndex(presentedActionMenuItemID == item.listID ? 1 : 0)
                        .task {
                            await viewModel.loadNextPageIfNeeded(currentItem: item)
                        }
                }
                .transition(.opacity)
            }

            if viewModel.isLoadingNextPage {
                ProgressView()
                    .padding(.vertical, 12)
            }
        }
    }

    private func actionMenuBinding(for item: BookSearchItem) -> Binding<Bool> {
        Binding(
            get: { presentedActionMenuItemID == item.listID },
            set: { isPresented in
                if isPresented {
                    presentedActionMenuItemID = item.listID
                } else if presentedActionMenuItemID == item.listID {
                    presentedActionMenuItemID = nil
                }
            }
        )
    }

}

private struct RecentKeywordRow: View {
    let keyword: String
    let onSelect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Button(action: onSelect) {
                Text(keyword)
                    .body2RegularStyle
                    .foregroundStyle(Color.gray600)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.gray500)
                    .frame(width: 12, height: 12)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 18)
    }
}

#Preview {
    SearchView()
}
