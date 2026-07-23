import SwiftUI

struct MonthYearPickerView: View {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    @State private var showPicker = false

    private var label: String {
        switch (selectedYear, selectedMonth) {
        case (0, _): return "전체"
        case (let y, 0): return "\(y)년"
        case (let y, let m): return "\(y)년 \(m)월"
        }
    }

    private var availableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 0)...(currentYear + 3))
    }

    var body: some View {
        Button {
            showPicker = true
        } label: {
            HStack(spacing: 8) {
                Text(label)
                    .caption1RegularStyle
                    .foregroundStyle(Color.gray800)
                Image(.iconChevronDown)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray200, lineWidth: 0.5)
            }
        }
        .popover(isPresented: $showPicker, arrowEdge: .top) {
            pickerContent
                .presentationCompactAdaptation(.popover)
        }
    }

    private var pickerContent: some View {
        HStack(spacing: 0) {
            Picker("년도", selection: $selectedYear) {
                Text("전체").tag(0)
                ForEach(availableYears, id: \.self) { year in
                    Text(verbatim: "\(year)년").tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 130)

            Picker("월", selection: $selectedMonth) {
                Text("전체").tag(0)
                ForEach(1...12, id: \.self) { month in
                    Text("\(month)월").tag(month)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 90)
        }
        .padding(.horizontal, 8)
        .frame(height: 180)
    }
}

#Preview {
    @Previewable @State var year = 2026
    @Previewable @State var month = 7
    MonthYearPickerView(selectedYear: $year, selectedMonth: $month)
}
