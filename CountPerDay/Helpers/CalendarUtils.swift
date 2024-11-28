import Foundation

struct CalendarUtils {
    static let totalDaysInWeek = 7
    static let totalRowsInGrid = 6
    static let weekdayOffset = -2

    // 指定された行と列から日付を計算
    static func calculateDay(row: Int, column: Int, firstDayWeekdayOffset: Int, totalDaysInMonth: Int) -> String {
        let day = row * totalDaysInWeek + column - firstDayWeekdayOffset
        return day > 0 && day <= totalDaysInMonth ? "\(day)" : ""
    }

    // 今日の日付かどうかを確認
    static func isToday(_ day: String, currentDate: Date) -> Bool {
        guard let dayInt = Int(day) else { return false }
        let calendar = Calendar.current
        let today = calendar.component(.day, from: Date())
        return calendar.isDateInToday(currentDate) && dayInt == today
    }

    // 日付に基づくキーを生成
    static func keyFor(day: String, currentDate: Date) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        // 日付のキーを yyyy-MM-dd 形式で作成（ゼロ埋め）
            return String(format: "%04d-%02d-%02d", year, month, day)
    }
}
