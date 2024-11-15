import SwiftUI

struct ContentView: View {
    @State private var currentDate = Date()
    private let calendar = Calendar.current

    private var currentYear: String {
        String(calendar.component(.year, from: currentDate))
    }

    private var currentMonth: String {
        String(calendar.component(.month, from: currentDate))
    }

    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 30
    }

    private var firstDayOfMonthWeekday: Int {
        let firstDay = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentDate),
                                                          month: calendar.component(.month, from: currentDate))) ?? Date()
        return calendar.component(.weekday, from: firstDay) - 2
    }

    private var today: Int {
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
    }

    private var headerView: some View {
        Text("\(currentYear)年 \(currentMonth)月")
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
        ForEach(0..<6) { row in
            HStack {
                ForEach(0..<7) { column in
                    ZStack(alignment: .topLeading) {
                        let day = dayFor(row: row, column: column)
                        Rectangle()
                            .fill(isToday(day) ? Color.blue : Color.gray.opacity(0.2))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .cornerRadius(8)
                        Text(day)
                            .padding(5)
                            .foregroundColor(isToday(day) ? .white : .primary)
                    }
                }
            }
        }
    }

    private func dayFor(row: Int, column: Int) -> String {
        let day = row * 7 + column - firstDayOfMonthWeekday
        return day > 0 && day <= daysInMonth ? "\(day)" : ""
    }

    private func isEmpty(_ row: Int, column: Int) -> Bool {
        let day = row * 7 + column - firstDayOfMonthWeekday
        return day <= 0 || day > daysInMonth
    }

    private func isToday(_ day: String) -> Bool {
        guard let dayInt = Int(day),
              calendar.isDate(Date(), equalTo: currentDate, toGranularity: .month) else {
            return false
        }
        return dayInt == today
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
