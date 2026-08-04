//
//  SearchViewModel.swift
//  BookBetween
//
//  Created by 이준성 on 7/8/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class SearchViewModel {
    var searchText: String = ""
    private(set) var recentKeywords: [String] = []
    private(set) var searchResults: [BookSearchItem] = []
    private(set) var isSearching = false
    private(set) var isLoadingNextPage = false
    private(set) var isRefreshing = false
    private(set) var hasSearched = false
    var errorMessage: String?

    private let service: any BookServiceProtocol
    private let pageSize: Int
    private var currentPage = 0
    private var hasNext = false
    private var submittedQuery = ""

    var bookService: any BookServiceProtocol {
        service
    }

    init(
        service: any BookServiceProtocol,
        pageSize: Int = 15
    ) {
        self.service = service
        self.pageSize = pageSize
    }

    func loadRecentSearches() async {
        do {
            recentKeywords = try await service.fetchRecentSearches().map(\.keyword)
        } catch {
            recentKeywords = []
            #if DEBUG
            print("[Recent Search] 최근 검색어 로딩 실패: \(error)")
            #endif
        }
    }

    func submitSearch() async {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else {
            resetSearch()
            return
        }
        guard !isSearching else { return }

        isSearching = true
        errorMessage = nil
        defer { isSearching = false }

        do {
            let result = try await service.searchBooks(
                query: keyword,
                page: 1,
                size: pageSize,
                saveRecent: true
            )

            searchResults = result.books
            currentPage = result.page
            hasNext = result.hasNext
            submittedQuery = keyword
            hasSearched = true

            recentKeywords.removeAll { $0 == keyword }
            recentKeywords.insert(keyword, at: 0)
            recentKeywords = Array(recentKeywords.prefix(5))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        guard !isSearching, !isLoadingNextPage, !isRefreshing else { return }

        guard hasSearched, !submittedQuery.isEmpty else {
            await loadRecentSearches()
            return
        }

        isRefreshing = true
        errorMessage = nil
        defer { isRefreshing = false }

        do {
            let result = try await service.searchBooks(
                query: submittedQuery,
                page: 1,
                size: pageSize,
                saveRecent: false
            )

            searchResults = result.books
            currentPage = result.page
            hasNext = result.hasNext
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadNextPageIfNeeded(currentItem: BookSearchItem) async {
        guard
            currentItem.listID == searchResults.last?.listID,
            hasNext,
            !isSearching,
            !isLoadingNextPage,
            !submittedQuery.isEmpty
        else { return }

        guard currentPage < 50 else {
            hasNext = false
            return
        }

        isLoadingNextPage = true
        errorMessage = nil
        defer { isLoadingNextPage = false }

        do {
            let result = try await service.searchBooks(
                query: submittedQuery,
                page: currentPage + 1,
                size: pageSize,
                saveRecent: true
            )

            searchResults.append(contentsOf: result.books)
            currentPage = result.page
            hasNext = result.hasNext
        } catch let error as NetworkError {
            switch error {
            case .decoding, .emptyResult:
                hasNext = false
                #if DEBUG
                print(
                    "[Book Search] 마지막 페이지 응답 처리 중단: \(error)"
                )
                #endif
            case .transport, .server:
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectRecentKeyword(_ keyword: String) {
        searchText = keyword
    }

    func removeRecentKeyword(_ keyword: String) {
        recentKeywords.removeAll { $0 == keyword }
    }

    private func resetSearch() {
        searchText = ""
        searchResults = []
        currentPage = 0
        hasNext = false
        submittedQuery = ""
        hasSearched = false
        errorMessage = nil
    }
}
