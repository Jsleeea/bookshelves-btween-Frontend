//
//  BookProgressView.swift
//  BookBetween
//
//  Created by 이준성 on 7/13/26.
//


import SwiftUI

struct BookProgressView: View {
    @Binding var progress: Int
    var isEditable: Bool = false

    private let barHeight: CGFloat = 3
    private let knobSize: CGFloat = 12

    init(progress: Int) {
        self._progress = .constant(progress)
        self.isEditable = false
    }

    init(progress: Binding<Int>, isEditable: Bool = true) {
        self._progress = progress
        self.isEditable = isEditable
    }

    private var clampedProgress: Int {
        min(max(progress, 0), 100)
    }

    private var progressRatio: CGFloat {
        CGFloat(clampedProgress) / 100
    }

    private var knobImageName: String {
        if clampedProgress == 0 {
            return "icon_progress_knob_empty"
        }
        return "icon_progress_knob_fill"
    }

    private func updateProgress(dragX: CGFloat, fullWidth: CGFloat) {
        guard fullWidth > knobSize else { return }
        let ratio = (dragX - knobSize / 2) / (fullWidth - knobSize)
        progress = Int((min(max(ratio, 0), 1) * 100).rounded())
    }

    var body: some View {
        HStack(spacing: 8) {
            GeometryReader { geo in
                let fullWidth = geo.size.width
                let knobX = knobSize / 2 + (fullWidth - knobSize) * progressRatio

                ZStack(alignment: .leading) {
                    // 배경 트랙
                    Capsule()
                        .fill(.green50)
                        .frame(height: barHeight)

                    // 채워진 부분 (그라데이션)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.green50, .green800],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: fullWidth, height: barHeight)
                        .mask(alignment: .leading) {
                            Capsule()
                                .frame(width: knobX, height: barHeight)
                        }

                    // 손잡이
                    Image(knobImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: knobSize, height: knobSize)
                        .position(x: knobX, y: geo.size.height / 2)
                }
                .frame(height: geo.size.height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard isEditable else { return }
                            updateProgress(dragX: value.location.x, fullWidth: fullWidth)
                        }
                )
            }
            .frame(height: knobSize)

            Text("\(clampedProgress)%")
                .caption2SemiBoldStyle
                .foregroundStyle(.green800)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        BookProgressView(progress: 0)
        BookProgressView(progress: 40)
        BookProgressView(progress: 100)
    }
    .padding()
}
