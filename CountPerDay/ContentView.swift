import SwiftUI

struct ContentView: View {
    @State private var currentDate = Date()
    private let calendar = Calendar.current
    
    // カウントデータの読込・保存
    @AppStorage("dailyCounts") private var dailyCountsData: Data?
    @State private var dailyCounts: [String: Int] = [:]
    
    // 定数
    private let totalDaysInWeek = 7
    private let totalRowsInGrid = 6
    private let weekdayOffset = -2
    
    // 現在の日付に基づく情報
    private var yearForCurrentDate: String {
        String(calendar.component(.year, from: currentDate))
    }
    
    private var monthForCurrentDate: String {
        String(calendar.component(.month, from: currentDate))
    }
    
    private var totalDaysInMonth: Int {
        calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 30
    }
    
    private var firstDayWeekdayOffset: Int {
        let firstDay = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentDate),
                                                          month: calendar.component(.month, from: currentDate))) ?? Date()
        return calendar.component(.weekday, from: firstDay) + weekdayOffset
    }
    
    private var currentDay: Int {
        calendar.component(.day, from: Date())
    }
    
    var body: some View {
        VStack {
            headerView
            controlButtons
            weekdayHeader
            dateGrid
        }
        .padding()
        .onAppear {
            loadDailyCounts()
        }
    }
    
    private var headerView: some View {
        Text("\(yearForCurrentDate)年 \(monthForCurrentDate)月")
            .font(.largeTitle)
            .padding()
    }
    
    private var controlButtons: some View {
        HStack {
            Button(action: showPreviousMonth) {
                Text("< 前月")
                    .buttonStyle
            }
            
            Spacer()
            
            Button(action: showNextMonth) {
                Text("次月 >")
                    .buttonStyle
            }
        }
        .padding(0.1)
    }
    
    private var weekdayHeader: some View {
        HStack {
            ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
            }
        }
        .font(.headline)
    }
    
    private var dateGrid: some View {
        ForEach(0..<totalRowsInGrid, id: \.self) { row in
            HStack {
                ForEach(0..<totalDaysInWeek, id: \.self) { column in
                    let day = calculateDay(row: row, column: column)
                    DateCellView(
                        day: day,
                        isToday: isToday(day),
                        count: dayCount(for: day),
                        onTap: { incrementCount(for: day) }
                    )
                }
            }
        }
    }

    // サブビューを分離
    private struct DateCellView: View {
        let day: String
        let isToday: Bool
        let count: Int?
        let onTap: () -> Void

        var body: some View {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(isToday ? Color.blue : Color.gray.opacity(0.2))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(8)
                    .onTapGesture {
                        onTap()
                    }

                Text(day)
                    .padding(5)
                    .foregroundColor(isToday ? .white : .primary)

                if let count = count {
                    Text("\(count)")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding(5)
                        .foregroundColor(isToday ? .white : .black)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            }
        }
    }

    // ヘルパー関数
    private func dayCount(for day: String) -> Int? {
        guard let dayInt = Int(day) else { return nil }
        return dailyCounts[keyFor(dayInt)]
    }

    // 指定された行と列から日付を計算
    private func calculateDay(row: Int, column: Int) -> String {
        let day = row * totalDaysInWeek + column - firstDayWeekdayOffset
        return day > 0 && day <= totalDaysInMonth ? "\(day)" : ""
    }
    
    // 指定された日付が今日かどうかを判定
    private func isToday(_ day: String) -> Bool {
        guard let dayInt = Int(day),
              calendar.isDate(currentDate, equalTo: Date(), toGranularity: .day) else {
            return false
        }
        return dayInt == currentDay
    }
    
    // 前月を表示
    private func showPreviousMonth() {
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = previousMonth
        }
    }
    
    // 次月を表示
    private func showNextMonth() {
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = nextMonth
        }
    }
    
    // 日付に基づくキーを生成
    private func keyFor(_ day: Int) -> String {
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        return "\(year)-\(month)-\(day)"
    }
    
    // 日付に関連付けられたカウントを増加
    private func incrementCount(for day: String) {
        guard let dayInt = Int(day) else { return }
        let key = keyFor(dayInt)
        dailyCounts[key, default: 0] += 1
        saveDailyCounts()
    }
    
    // データをロード
    private func loadDailyCounts() {
        guard let data = dailyCountsData else { return }
        do {
            let decodedCounts = try JSONDecoder().decode([String: Int].self, from: data)
            dailyCounts = decodedCounts
        } catch {
            print("Failed to decode dailyCounts: \(error)")
        }
    }
    
    // データを保存
    private func saveDailyCounts() {
        do {
            let data = try JSONEncoder().encode(dailyCounts)
            dailyCountsData = data
        } catch {
            print("Failed to encode dailyCounts: \(error)")
        }
    }
}

private extension Text {
    var buttonStyle: some View {
        self.padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.black)
            .cornerRadius(8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
