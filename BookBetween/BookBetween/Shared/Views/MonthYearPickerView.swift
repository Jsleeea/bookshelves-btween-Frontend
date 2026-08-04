import SwiftUI

struct MonthYearPickerView: View {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    @State private var showPicker = false

    private let availableYears: [Int]
    private let includesAllOption: Bool
    private let startYear: Int
    private let startMonth: Int

    init(
        selectedYear: Binding<Int>,
        selectedMonth: Binding<Int>,
        startYear: Int? = nil,
        startMonth: Int = 1,
        availableYears: [Int]? = nil,
        includesAllOption: Bool = true
    ) {
        let currentYear = Calendar.current.component(.year, from: Date())

        _selectedYear = selectedYear
        _selectedMonth = selectedMonth
        self.includesAllOption = includesAllOption
        self.startMonth = startMonth

        let resolvedStartYear: Int
        if let startYear {
            resolvedStartYear = startYear
        } else if let availableYears {
            resolvedStartYear = availableYears.min() ?? currentYear
        } else {
            resolvedStartYear = currentYear - 3
        }
        self.startYear = resolvedStartYear
        self.availableYears = availableYears.map { Array($0.reversed()) } ?? Array((resolvedStartYear...currentYear).reversed())
    }

    private var label: String {
        switch (selectedYear, selectedMonth) {
        case (0, _): return "전체"
        case (let y, 0): return "\(y)년"
        case (let y, let m): return "\(y)년 \(m)월"
        }
    }

    private var availableMonths: [Int] {
        guard selectedYear == startYear else { return Array(1...12) }
        return Array(startMonth...12)
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
                if includesAllOption {
                    Text("전체").tag(0)
                }

                ForEach(availableYears, id: \.self) { year in
                    Text(verbatim: "\(year)년").tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 130)
            .onChange(of: selectedYear) { _, newYear in
                if includesAllOption, newYear == 0 {
                    selectedMonth = 0
                    return
                }
                // 시작 연도 선택 시 시작 월 이전이면 시작 월로 보정
                if newYear == startYear, selectedMonth != 0, selectedMonth < startMonth {
                    selectedMonth = startMonth
                }
            }

            Picker("월", selection: $selectedMonth) {
                if includesAllOption {
                    Text("전체").tag(0)
                }

                ForEach(availableMonths, id: \.self) { month in
                    Text("\(month)월").tag(month)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 90)
            .disabled(includesAllOption && selectedYear == 0)
            .opacity(includesAllOption && selectedYear == 0 ? 0.4 : 1)
        }
        .padding(.horizontal, 8)
        .frame(height: 180)
    }
}

#Preview {
    @Previewable @State var year = 0
    @Previewable @State var month = 0
    MonthYearPickerView(selectedYear: $year, selectedMonth: $month)
}
