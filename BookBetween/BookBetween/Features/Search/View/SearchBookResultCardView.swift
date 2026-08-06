//
//  SearchBookResultCardView.swift
//  BookBetween
//
//  Created by 이준성 on 7/9/26.
//

import SwiftUI

struct SearchBookResultCardView: View {
    private static let cardHeight: CGFloat = 110
    private static let menuTopOffset: CGFloat = 48
    private static let menuHeight: CGFloat = 111

    let item: BookSearchItem
    let service: any BookServiceProtocol
    let meetingService: (any MeetingServiceProtocol)?
    @Binding private var isActionMenuPresented: Bool

    init(
        item: BookSearchItem,
        service: any BookServiceProtocol = BookService.stubbed(),
        meetingService: (any MeetingServiceProtocol)? = nil,
        isActionMenuPresented: Binding<Bool> = .constant(false)
    ) {
        self.item = item
        self.service = service
        self.meetingService = meetingService
        _isActionMenuPresented = isActionMenuPresented
    }

    private var book: Book {
        item.book
    }

    private var bookSubtitle: String {
        guard
            let publisher = book.publisher,
            !publisher.isEmpty
        else {
            return book.author
        }

        return "\(book.author) | \(publisher)"
    }

    var body: some View {
        cardContent
            .overlay(alignment: .topTrailing) {
                if isActionMenuPresented {
                    actionMenu
                        .padding(.top, Self.menuTopOffset)
                        .padding(.trailing, 12)
                        .transition(
                            .scale(scale: 0.95, anchor: .topTrailing)
                                .combined(with: .opacity)
                        )
                }
            }
            .padding(
                .bottom,
                isActionMenuPresented ? Self.menuOverflowHeight : 0
            )
            .animation(.easeInOut(duration: 0.15), value: isActionMenuPresented)
    }

    private static var menuOverflowHeight: CGFloat {
        max(menuTopOffset + menuHeight - cardHeight, 0)
    }

    private var cardContent: some View {
        HStack(alignment: .top, spacing: 10) {
            BookCoverImage(book: book, placeholderImageName: "book_cover_mock")
                .frame(width: 65, height: 95)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray200, lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 6) {
                Spacer()

                Text(book.title)
                    .body1SemiBoldStyle
                    .foregroundStyle(Color.gray800)
                    .lineLimit(1)

                Text(bookSubtitle)
                    .body2RegularStyle
                    .foregroundStyle(Color.gray500)
                    .lineLimit(1)

                Spacer()
            }
            .frame(height: 96)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isActionMenuPresented.toggle()
                }
            } label: {
                Image(
                    isActionMenuPresented
                        ? "icon_add_fill"
                        : "icon_add_empty"
                )
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .padding(.top, 9)
        }
        .padding(.horizontal, 21)
        .padding(.vertical, 7)
        .frame(height: Self.cardHeight)
        .background(isActionMenuPresented ? Color.gray100 : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray300, lineWidth: 0.5)
        }
    }

    private var actionMenu: some View {
        VStack(spacing: 0) {
            NavigationLink(value: SearchRoute.createMeeting(book)) {
                actionMenuRow(
                    iconName: "icon_search_group",
                    title: "모임 생성하기",
                    subtitle: "이 책으로 모임을 만들어 보세요"
                )
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded {
                isActionMenuPresented = false
            })

            Divider()
                .background(Color.gray300)

            NavigationLink(value: SearchRoute.bookDetail(item)) {
                actionMenuRow(
                    iconName: "icon_search_tag",
                    title: "내 서재에 추가",
                    subtitle: "내 서재에 책을 저장해 보세요"
                )
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded {
                isActionMenuPresented = false
            })
        }
        .frame(width: 216)
        .frame(height: Self.menuHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray300, lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
    }

    private func actionMenuRow(
        iconName: String,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .caption2SemiBoldStyle
                    .foregroundStyle(Color.gray800)

                Text(subtitle)
                    .caption2RegularStyle
                    .foregroundStyle(Color.gray600)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .frame(height: 55)
        .contentShape(Rectangle())
    }
}

#Preview {
    SearchBookResultCardView(
        item: BookSearchItem(
            book: Book(
                isbn: "9788936434595",
                title: "혼모노",
                author: "성해나",
                publisher: "창비"
            ),
            isSaveable: true
        )
    )
    .padding()
}
