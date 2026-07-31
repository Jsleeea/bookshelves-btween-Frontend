//
//  AccountRecoveryView.swift
//  BookBetween
//

import SwiftUI

struct AccountRecoveryView: View {
    @State private var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.beige100
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 76, weight: .regular))
                    .foregroundStyle(Color.green600)
                    .padding(.bottom, 28)

                Text("계정을 복구할까요?")
                    .head1Style
                    .foregroundStyle(Color.gray900)

                Text("탈퇴 대기 중인 계정이에요.\n복구하면 기존 정보를 다시 이용할 수 있어요.")
                    .body1RegularStyle
                    .foregroundStyle(Color.gray600)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)

                VStack(spacing: 6) {
                    Text("계정 삭제 예정일")
                        .caption1RegularStyle
                        .foregroundStyle(Color.gray600)

                    Text(scheduledDeletionText)
                        .body1SemiBoldStyle
                        .foregroundStyle(Color.gray800)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray200, lineWidth: 1)
                }
                .padding(.horizontal, 29)
                .padding(.top, 32)

                Spacer()

                Button {
                    Task {
                        await viewModel.restoreAccount()
                    }
                } label: {
                    Group {
                        if viewModel.isRecoveringAccount {
                            ProgressView()
                                .tint(Color.white)
                        } else {
                            Text("계정 복구하기")
                                .head3Style
                        }
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 53)
                    .background(Color.green600)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.isRecoveringAccount)

                Button {
                    viewModel.cancelAccountRecovery()
                } label: {
                    Text("복구하지 않고 로그인 화면으로 돌아가기")
                        .body2RegularStyle
                        .foregroundStyle(Color.gray600)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .disabled(viewModel.isRecoveringAccount)
                .padding(.top, 8)
            }
            .padding(.horizontal, 29)
            .padding(.bottom, 24)
        }
        .alert(
            "계정을 복구하지 못했습니다.",
            isPresented: Binding(
                get: {
                    viewModel.accountRecoveryErrorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.accountRecoveryErrorMessage = nil
                    }
                }
            )
        ) {
            Button("확인", role: .cancel) {
                viewModel.accountRecoveryErrorMessage = nil
            }
        } message: {
            Text(
                viewModel.accountRecoveryErrorMessage
                    ?? "다시 시도해주세요."
            )
        }
    }

    private var scheduledDeletionText: String {
        guard let scheduledDeletionAt = viewModel.scheduledDeletionAt,
              !scheduledDeletionAt.isEmpty else {
            return "삭제 예정일을 확인할 수 없습니다."
        }

        let formatter = ISO8601DateFormatter()

        guard let date = formatter.date(from: scheduledDeletionAt) else {
            return scheduledDeletionAt
        }

        return date.formatted(
            .dateTime
                .locale(Locale(identifier: "ko_KR"))
                .year()
                .month()
                .day()
        )
    }
}
