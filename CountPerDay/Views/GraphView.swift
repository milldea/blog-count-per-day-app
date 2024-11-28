import SwiftUI
import Charts

struct GraphView: View {
    let monthlyCounts: [String: Int]

    var body: some View {
        let sortedCounts = monthlyCounts.sorted { lhs, rhs in
            lhs.key < rhs.key
        }

        VStack {
            Chart {
                // データの描画
                ForEach(sortedCounts, id: \.key) { day, count in
                    LineMark(
                        x: .value("日付", dayAsInt(day)),
                        y: .value("カウント", count)
                    )
                }

                // 7日ごとの縦線を追加
                ForEach(1...31, id: \.self) { day in
                    if day % 7 == 1 {
                        RuleMark(
                            x: .value("日付", day)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 0.5, dash: [5]))
                        .foregroundStyle(Color.gray.opacity(0.3))
                    }
                }
            }
            .chartYScale(domain: 0...maxCount(sortedCounts))
            .chartXAxis {
                AxisMarks(values: .stride(by: 7)) { value in  // 7日区切り
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue+1)日") // 0日始まりにならないように+1する
                                .font(.caption)
                                .rotationEffect(.degrees(-45))  // 日付ラベルを45度回転
                        }
                    }
                }
            }
            .padding([.leading, .trailing])
            .frame(height: 300)
        }
    }

    // 日付キーから日を抽出
    private func dayAsInt(_ key: String) -> Int {
            Int(key.split(separator: "-").last ?? "0") ?? 0
        }

    // 最大カウントの取得
    private func maxCount(_ counts: [(key: String, value: Int)]) -> Int {
        counts.map { $0.value }.max() ?? 10
    }
}

struct GraphView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView(monthlyCounts: [
            "2024-11-01": 5,
            "2024-11-02": 0,
            "2024-11-03": 3,
            "2024-11-04": 7,
            "2024-11-05": 2,
            "2024-11-06": 4,
            "2024-11-07": 0,
            "2024-11-08": 3,
            "2024-11-09": 1,
            "2024-11-10": 2,
            "2024-11-11": 6,
            "2024-11-12": 3,
            "2024-11-13": 1,
            "2024-11-14": 2,
            "2024-11-15": 4,
            "2024-11-16": 2,
            "2024-11-17": 3,
            "2024-11-18": 4,
            "2024-11-19": 1,
            "2024-11-20": 5,
            "2024-11-21": 6,
            "2024-11-22": 3,
            "2024-11-23": 0,
            "2024-11-24": 2,
            "2024-11-25": 3,
            "2024-11-26": 5,
            "2024-11-27": 4,
            "2024-11-28": 0,
            "2024-11-29": 1,
            "2024-11-30": 2
        ])
    }
}
