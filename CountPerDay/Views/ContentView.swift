import SwiftUI

struct ContentView: View {
    @State private var currentDate = Date()
    private let calendar = Calendar.current
    
    @AppStorage("dailyCounts") private var dailyCountsData: Data?
    @State private var dailyCounts: [String: Int] = [:]
    
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
                        onTap: { incrementCount(for: day) }
                    )
                }
            }
        }
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
