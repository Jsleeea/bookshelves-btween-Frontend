//
//  NotificationInboxView.swift
//  BookBetween
//

import SwiftUI

@MainActor
struct NotificationInboxView: View {
    private enum NotificationDestination {
        case summary(BookMeeting)
        case chat(BookMeeting)
    }

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: NotificationInboxViewModel
    @State private var destination: NotificationDestination?
    @State private var isDestinationPresented = false
    @State private var isMeetingEndedModalPresented = false

    private let meetingService: (any MeetingServiceProtocol)?
    private let chatService: (any ChatServiceProtocol)?
    private let chatSocketService: (any ChatSocketServiceProtocol)?

    init(
        viewModel: NotificationInboxViewModel,
        meetingService: (any MeetingServiceProtocol)? = nil,
        chatService: (any ChatServiceProtocol)? = nil,
        chatSocketService: (any ChatSocketServiceProtocol)? = nil
    ) {
        self.meetingService = meetingService
        self.chatService = chatService
        self.chatSocketService = chatSocketService
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.gray50
                .ignoresSafeArea()
                .overlay(alignment: .bottomLeading) {
                    bottomLeadingGradient
                }

            VStack(spacing: 0) {
                navigationHeader

                if viewModel.isEmpty {
                    emptyState
                } else {
                    notificationList
                }
            }
            .padding(.top, 8)

            leafDecoration
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            if isMeetingEndedModalPresented {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isMeetingEndedModalPresented = false
                    }

                ErrorModalView(title: "종료된 모임입니다") {
                    isMeetingEndedModalPresented = false
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isMeetingEndedModalPresented)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .enableSwipeBack()
        .overlay {
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                ProgressView()
            }
        }
        .task {
            await viewModel.start()
        }
        .navigationDestination(isPresented: $isDestinationPresented) {
            notificationDestinationView
        }
        .alert(
            "알림을 불러오지 못했습니다.",
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

    private var navigationHeader: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image("icon_arrow_left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)

            Text("알림함")
                .head1Style
                .foregroundStyle(.gray900)

            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 18)
    }

    private var notificationList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.notifications) { notification in
                    Button {
                        Task {
                            await handleNotificationTap(notification)
                        }
                    } label: {
                        NotificationCardView(item: notification)
                    }
                    .buttonStyle(.plain)
                    .task {
                        await viewModel.loadNextPageIfNeeded(
                            currentItem: notification
                        )
                    }
                }

                if viewModel.isLoadingNextPage {
                    ProgressView()
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 40)
        }
        .refreshable {
            await viewModel.refreshNotifications()
        }
    }

    @ViewBuilder
    private var notificationDestinationView: some View {
        switch destination {
        case .summary(let meeting):
            BookMeetingResultView(
                meeting: meeting,
                service: meetingService
            )
        case .chat(let meeting):
            if let chatService, let chatSocketService {
                ChatView(
                    viewModel: ChatViewModel(
                        chatroomId: meeting.chatroomId,
                        meetingId: meeting.id,
                        chatService: chatService,
                        socketService: chatSocketService
                    )
                )
            } else {
                ChatView(
                    chatroomId: meeting.chatroomId,
                    meetingId: meeting.id
                )
            }
        case nil:
            EmptyView()
        }
    }

    private func handleNotificationTap(_ notification: NotificationItem) async {
        await viewModel.markAsRead(notification)

        guard notification.isActionable,
              let meetingId = notification.targetId,
              let meetingService else {
            return
        }

        switch notification.type {
        case .aiSummaryReady:
            do {
                let meeting = try await meetingService.fetchMeetingDetail(
                    meetingId: meetingId
                )
                destination = .summary(meeting)
                isDestinationPresented = true
            } catch {
                #if DEBUG
                print("""
                [알림함] AI 요약 진입 실패
                notificationId: \(notification.id)
                targetId(meetingId): \(meetingId)
                error: \(error)
                """)
                #endif

                viewModel.errorMessage = error.localizedDescription
            }

        case .meetingStarted:
            do {
                let meeting = try await meetingService.fetchMeetingDetail(
                    meetingId: meetingId
                )

                guard case .inProgress = meeting.status,
                      meeting.chatroomId > 0 else {
                    isMeetingEndedModalPresented = true
                    return
                }

                destination = .chat(meeting)
                isDestinationPresented = true
            } catch {
                isMeetingEndedModalPresented = true
            }

        case .meetingCancelled, .system:
            break
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell")
                .font(.system(size: 32, weight: .regular))
                .foregroundStyle(.gray400)

            Text("새로운 알림이 없어요")
                .body1SemiBoldStyle
                .foregroundStyle(.gray600)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var leafDecoration: some View {
        Image("notification_leaf_right")
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 136)
            .opacity(0.55)
            .offset(x: 16, y: 30)
            .allowsHitTesting(false)
    }

    private var bottomLeadingGradient: some View {
        RadialGradient(
            stops: [
                .init(
                    color: Color(hex: "DCEBE1").opacity(0.4),
                    location: 0.3
                ),
                .init(
                    color: Color(hex: "DCEBE1").opacity(0),
                    location: 0.7
                )
            ],
            center: .center,
            startRadius: 0,
            endRadius: 281
        )
        .frame(width: 562, height: 454)
        .offset(x: -175, y: 209)
        .allowsHitTesting(false)
    }
}

#Preview("알림 목록") {
    NotificationInboxView(
        viewModel: NotificationInboxViewModel(
            service: NotificationService.stubbed()
        )
    )
}

#Preview("빈 알림함") {
    NotificationInboxView(
        viewModel: NotificationInboxViewModel(notifications: [])
    )
}
