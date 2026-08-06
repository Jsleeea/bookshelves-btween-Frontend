//
//  BookRecordDetailView.swift
//  BookBetween
//
//  Created by 이준성 on 7/11/26.
//

import SwiftUI

struct BookRecordDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: BookRecordDetailViewModel
    @State private var isShowingSaveSuccess = false
    @State private var editHintShakeTrigger: CGFloat = 0
    @FocusState private var isReviewFocused: Bool  // 키보드 내리기
    private let onRecordSaved: ((UserBookRecord) -> Void)?
    
    init(
        record: UserBookRecord,
        isSaveable: Bool = true,
        service: any BookServiceProtocol = BookService.stubbed(),
        loadsRemoteDetail: Bool = false,
        onRecordSaved: ((UserBookRecord) -> Void)? = nil
    ) {
        self.onRecordSaved = onRecordSaved
        _viewModel = State(
            initialValue: BookRecordDetailViewModel(
                record: record,
                isSaveable: isSaveable,
                service: service,
                loadsRemoteDetail: loadsRemoteDetail
            )
        )
    }

    init(
        book: Book,
        isSaveable: Bool = true,
        service: any BookServiceProtocol = BookService.stubbed(),
        loadsRemoteDetail: Bool = false,
        onRecordSaved: ((UserBookRecord) -> Void)? = nil
    ) {
        self.init(
            record: UserBookRecord(
                book: book,
                progress: 0,
                rating: nil,
                memo: nil
            ),
            isSaveable: isSaveable,
            service: service,
            loadsRemoteDetail: loadsRemoteDetail,
            onRecordSaved: onRecordSaved
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, 30)
                .padding(.bottom, 13)
                .zIndex(1)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if !viewModel.isLoading {
                        Group {
                            bookHeader
                            bookDescription
                            readingRecordForm
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
                .padding(.horizontal, 30)
                .padding(.bottom, 140)// 기록 저장하기 잘림 수정 140 - 40
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .padding(.top, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            isReviewFocused = false
        }
        .background(alignment: .topTrailing) {
            Image("leaf_img2")
                .resizable()
                .scaledToFit()
                .frame(width: 147, height: 133)
                .opacity(0.75)
                .offset(x: 13)
                .allowsHitTesting(false)
            }
        .toolbar(.hidden, for: .navigationBar)
        .enableSwipeBack()
        .overlay {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                }

                if isShowingSaveSuccess {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    SuccessModalView(title: "저장되었습니다.") {
                        isShowingSaveSuccess = false
                    }
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isShowingSaveSuccess)
        }
        .task {
            await viewModel.loadBookDetail()
        }
        .alert(
            "도서 정보를 처리하지 못했습니다.",
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

    // MARK: - 책정보, 수정하기
    private var topBar: some View {
        HStack(spacing: 8) {
            Button {
                dismiss()
            } label: {
                Image("icon_arrow_left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)

            Text("책 정보")
                .head2Style
                .foregroundStyle(.gray900)

            Spacer()

            Button {
                viewModel.startEditing()
            } label: {
                HStack(spacing: 6) {
                    Image("icon_pencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)

                    Text("수정하기")
                        .body1SemiBoldStyle
                }
                .foregroundStyle(.gray800)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isEditing || !viewModel.isSaveable)
            .opacity(viewModel.isEditing || !viewModel.isSaveable ? 0 : 1)
            .modifier(ShakeEffect(animatableData: editHintShakeTrigger))
        }
    }

    private func requestEditHint() {
        guard !viewModel.isEditing, viewModel.isSaveable else { return }

        withAnimation(.easeInOut(duration: 0.35)) {
            editHintShakeTrigger += 1
        }
    }

    // MARK: - 책 이미지, 제목
    private var bookHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            BookCoverImage(book: viewModel.book, placeholderImageName: "book_cover_mock")
                .scaledToFill()
                .frame(width: 105.4, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay {
                        RoundedRectangle(cornerRadius: 9)
                            .strokeBorder(.gray200, lineWidth: 1)
                }
            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.book.title)
                    .head2Style
                    .foregroundStyle(.gray800)
                    .lineLimit(1)

                Text(authorAndPublisherText)
                    .body1RegularStyle
                    .foregroundStyle(.gray500)

                if let categoryText {
                    Text(categoryText)
                        .body2SemiBoldStyle
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.green600)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.top, 16)
    }

    private var authorAndPublisherText: String {
        guard
            let publisher = viewModel.book.publisher?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !publisher.isEmpty
        else {
            return viewModel.book.author
        }

        return "\(viewModel.book.author) | \(publisher)"
    }

    private var categoryText: String? {
        guard
            let kdcName = viewModel.book.kdcName?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !kdcName.isEmpty
        else {
            return nil
        }

        return kdcName.hasPrefix("#") ? kdcName : "#\(kdcName)"
    }


    // MARK: - 글 설명
    private var bookDescription: some View {
        Text(viewModel.book.description ?? "")
            .caption1RegularStyle
            .foregroundStyle(.gray700)
            .lineSpacing(4)
            .lineLimit(4)
            .padding(.top, 25)
    }

    // MARK: - 독서 진행률, 평점, 한줄평, 저장하기
    private var readingRecordForm: some View {
        VStack(spacing: 0) {
            progressCard
            ratingCard
            reviewCard
            saveButton
        }
        .padding(.top, 44)
    }

    private var progressCard: some View {
        recordCard {
            VStack(alignment: .leading, spacing: 0) {
                Text("독서 진행률")
                    .body1SemiBoldStyle
                    .foregroundStyle(.gray800)

                BookProgressView(progress: $viewModel.progress, isEditable: viewModel.isEditing)
                    .frame(width: 288)
                    .padding(.top, 8)
            }
        }
        .simultaneousGesture(TapGesture().onEnded { requestEditHint() })
    }

    private let starSize: CGFloat = 20
    private let starSpacing: CGFloat = 4
    private var starsRowWidth: CGFloat { starSize * 5 + starSpacing * 4 }

    private var ratingCard: some View {
        recordCard {
            VStack(alignment: .leading, spacing: 0) {
                Text("평점")
                    .body1SemiBoldStyle
                    .foregroundStyle(.gray800)

                GeometryReader { geo in
                    HStack(spacing: starSpacing) {
                        ForEach(1...5, id: \.self) { score in
                            Image(starImageName(for: score))
                                .resizable()
                                .scaledToFit()
                                .frame(width: starSize, height: starSize)
                        }
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard viewModel.isEditing else { return }
                                updateRating(dragX: value.location.x, fullWidth: geo.size.width)
                            }
                    )
                }
                .frame(width: starsRowWidth, height: starSize)
                .padding(.top, 3)
            }
        }
        .simultaneousGesture(TapGesture().onEnded { requestEditHint() })
        .padding(.top, 8)
    }

    private func starImageName(for score: Int) -> String {
        let threshold = Double(score)
        if viewModel.rating >= threshold {
            return "icon_star_fill"
        } else if viewModel.rating >= threshold - 0.5 {
            return "icon_star_half"
        } else {
            return "icon_star_empty"
        }
    }

    private func updateRating(dragX: CGFloat, fullWidth: CGFloat) {
        guard fullWidth > 0 else { return }
        let ratio = min(max(dragX / fullWidth, 0), 1)
        let steppedScore = (ratio * 5 * 2).rounded() / 2
        viewModel.updateRating(steppedScore)
    }

    private var reviewCard: some View {
        recordCard(
            borderColor: viewModel.isEditing ? .green500 : .gray200,
            borderWidth: viewModel.isEditing ? 1.5 : 0.5
        ) {
            VStack(alignment: .leading, spacing: 5) {
                Text("한줄평")
                    .body1SemiBoldStyle
                    .foregroundStyle(.gray800)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $viewModel.memo)
                        .font(.caption1Regular)
                        .foregroundStyle(viewModel.isEditing ? Color.gray800 : Color.gray700)
                        .frame(maxWidth: .infinity, minHeight: 76, alignment: .topLeading)
                        .padding(.horizontal, -5)
                        .scrollContentBackground(.hidden)
                        .focused($isReviewFocused)
                        .allowsHitTesting(viewModel.isEditing)
                        .accessibilityLabel("한줄평")

                    if !viewModel.hasReview {
                        Text(viewModel.reviewPlaceholderText)
                            .font(.caption1Regular)
                            .foregroundStyle(viewModel.isEditing ? Color.gray800 : Color.gray500)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                }

                if viewModel.isEditing {
                    HStack {
                        Spacer()
                        Text("\(viewModel.memo.count) / \(BookRecordDetailViewModel.maxMemoLength)")
                            .caption2RegularStyle
                            .foregroundStyle(
                                viewModel.memo.count >= BookRecordDetailViewModel.maxMemoLength
                                    ? Color.red
                                    : Color.gray500
                            )
                    }
                }
            }
            .background (alignment: .bottomTrailing){
                Image("leaf_img1")
                    .resizable()
                    .scaledToFit()
                    .frame(width:82, height: 109)
                    .opacity(0.55)
                    .allowsHitTesting(false) // 배경 이미지가 TextEditor의 터치를 가로채지 않도록.
                    .offset(x: 18, y: 16) // padding 만큼 밀어냄
            }
        }
        .simultaneousGesture(TapGesture().onEnded { requestEditHint() })
        .padding(.top, 8)
    }
    
    private var saveButton: some View {
        Button {
            isReviewFocused = false
            Task {
                if let savedRecord = await viewModel.saveRecord() {
                    onRecordSaved?(savedRecord)
                    isShowingSaveSuccess = true
                }
            }
        } label: {
            Group {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("기록 저장하기")
                        .body1SemiBoldStyle
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(.green600)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.isEditing || viewModel.isSaving)
        .opacity(viewModel.isEditing ? 1 : 0)
        .padding(.top, 45.82)
    }

    private func recordCard<Content: View>(
        borderColor: Color = .gray200,
        borderWidth: CGFloat = 0.5,
        @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: borderWidth)
            }
    }
}

private struct ShakeEffect: GeometryEffect {
    var travelDistance: CGFloat = 6
    var numberOfShakes: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = travelDistance * sin(animatableData * .pi * numberOfShakes)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

#Preview {
    NavigationStack {
        BookRecordDetailView(
            record: UserBookRecord(
                book: Book(
                    id: 1,
                    title: "랑과 나의 사막",
                    author: "천선란",
                    description: "성해나 작가의 단편 소설집 혼모노는 진짜와 가짜, 믿음에 대한 날카로운 질문을 던지는 작품입니다.\n표제작 혼모노는 신발을 잃고 20대 애기 무당에게 자리를 빼앗긴 베테랑 무당이 진정한 자신의 정체성을 찾아가는 과정을 그립니다.",
                    kdcName: "한국문학"
                ),
                progress: 0,
                rating: nil,
                memo: nil
            )
        )
    }
}
