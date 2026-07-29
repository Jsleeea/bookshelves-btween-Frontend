//
//  NotificationInboxViewModel.swift
//  BookBetween
//

import Foundation
import Observation

@Observable
@MainActor
final class NotificationInboxViewModel {
    private(set) var notifications: [NotificationItem] = []
    private(set) var isLoading = false
    private(set) var isLoadingNextPage = false
    var errorMessage: String?

    private let service: any NotificationServiceProtocol
    private let pageSize: Int
    private let automaticallyLoads: Bool
    private var currentPage = 0
    private var hasNext = false
    private var hasLoaded = false
    private var readingNotificationIds: Set<Int> = []

    var isEmpty: Bool {
        notifications.isEmpty
    }

    init(
        service: any NotificationServiceProtocol,
        pageSize: Int = 20
    ) {
        self.service = service
        self.pageSize = pageSize
        self.automaticallyLoads = true
    }

    init(notifications: [NotificationItem]) {
        self.notifications = notifications
        self.service = NotificationService.stubbed()
        self.pageSize = 20
        self.automaticallyLoads = false
    }

    func start() async {
        guard automaticallyLoads else { return }

        await loadNotifications()
    }

    func loadNotifications() async {
        guard !hasLoaded, !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await service.fetchNotifications(
                page: 1,
                size: pageSize
            )
            notifications = result.notifications
            currentPage = result.page
            hasNext = result.hasNext
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshNotifications() async {
        guard automaticallyLoads, !isLoading else { return }

        hasLoaded = false
        currentPage = 0
        hasNext = false
        await loadNotifications()
    }

    func loadNextPageIfNeeded(currentItem: NotificationItem) async {
        guard
            currentItem.id == notifications.last?.id,
            hasNext,
            !isLoading,
            !isLoadingNextPage
        else { return }

        isLoadingNextPage = true
        errorMessage = nil
        defer { isLoadingNextPage = false }

        do {
            let result = try await service.fetchNotifications(
                page: currentPage + 1,
                size: pageSize
            )
            appendUnique(result.notifications)
            currentPage = result.page
            hasNext = result.hasNext
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAsRead(_ notification: NotificationItem) async {
        guard
            !notification.isRead,
            !readingNotificationIds.contains(notification.id)
        else { return }

        readingNotificationIds.insert(notification.id)
        defer { readingNotificationIds.remove(notification.id) }

        do {
            let notificationId = try await service.markAsRead(
                notificationId: notification.id
            )

            guard let index = notifications.firstIndex(
                where: { $0.id == notificationId }
            ) else { return }

            notifications[index] = notifications[index].markingAsRead()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func appendUnique(_ newNotifications: [NotificationItem]) {
        let existingIds = Set(notifications.map(\.id))
        notifications.append(
            contentsOf: newNotifications.filter {
                !existingIds.contains($0.id)
            }
        )
    }

}
