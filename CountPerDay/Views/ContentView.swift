import SwiftUI

struct ContentView: View {
    @State private var currentDate = Date()
    private let calendar = Calendar.current
    
    @AppStorage("dailyCounts") private var dailyCountsData: Data?
    @State private var dailyCounts: [String: Int] = [:]
    @State private var isGraphViewPresented = false

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
        return calendar.component(.weekday, from: firstDay) + CalendarUtils.weekdayOffset
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
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height < -100 { // 上方向のスワイプを検出
                        isGraphViewPresented = true
                    }
                }
        )
        .sheet(isPresented: $isGraphViewPresented) {
            GraphView(monthlyCounts: monthlyCounts())
            .presentationDetents([.fraction(0.5)])
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
                    .modifier(ButtonStyleModifier())
            }

            Spacer()

            Button(action: showNextMonth) {
                Text("次月 >")
                    .modifier(ButtonStyleModifier())
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
        ForEach(0..<CalendarUtils.totalRowsInGrid, id: \.self) { row in
            HStack {
                ForEach(0..<CalendarUtils.totalDaysInWeek, id: \.self) { column in
                    let day = CalendarUtils.calculateDay(
                        row: row,
                        column: column,
                        firstDayWeekdayOffset: firstDayWeekdayOffset,
                        totalDaysInMonth: totalDaysInMonth
                    )
                    DateCellView(
                        day: day,
                        isToday: CalendarUtils.isToday(day, currentDate: currentDate),
                        count: dailyCounts[CalendarUtils.keyFor(day: day, currentDate: currentDate)],
                        onTap: { incrementCount(for: day) },
                        onLongPress: { resetCount(for: day) }
                    )
                }
            }
        }
    }

    private func monthlyCounts() -> [String: Int] {
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let range = calendar.range(of: .day, in: .month, for: currentDate) ?? 1..<31

        var completeCounts: [String: Int] = [:]
        for day in range {
            // 日付のキーを yyyy-MM-dd 形式で作成
            let key = String(format: "%04d-%02d-%02d", year, month, day)
            // dailyCounts にその日のデータがあれば取得、なければ 0
            completeCounts[key] = dailyCounts[key] ?? 0
        }
        
        // 日付順にソート
        let sortedCounts = completeCounts.keys.sorted { (date1, date2) -> Bool in
            guard let dateObject1 = dateFormatter.date(from: date1), let dateObject2 = dateFormatter.date(from: date2) else {
                return false
            }
            return dateObject1 < dateObject2
        }
        for day in range {
            let key = String(format: "%04d-%02d-%02d", year, month, day)
            completeCounts[key] = dailyCounts[key] ?? 0
        }
        
        return sortedCounts.reduce(into: [String: Int]()) { result, key in
            result[key] = completeCounts[key]
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    private func resetCount(for day: String) {
        let key = CalendarUtils.keyFor(day: day, currentDate: currentDate)
        dailyCounts[key] = nil
        saveDailyCounts()
    }

    private func loadDailyCounts() {
        dailyCounts = DataManager.loadDailyCounts(from: dailyCountsData)
    }

    private func saveDailyCounts() {
        dailyCountsData = DataManager.saveDailyCounts(dailyCounts)
    }

    private func incrementCount(for day: String) {
        let key = CalendarUtils.keyFor(day: day, currentDate: currentDate)
        dailyCounts[key, default: 0] += 1
        saveDailyCounts()
    }

    private func showPreviousMonth() {
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = previousMonth
        }
    }
    
    private func showNextMonth() {
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = nextMonth
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
