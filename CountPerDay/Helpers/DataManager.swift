import Foundation

struct DataManager {
    // カウントデータの読み込み
    static func loadDailyCounts(from data: Data?) -> [String: Int] {
        guard let data = data else { return [:] }
        do {
            let decodedCounts = try JSONDecoder().decode([String: Int].self, from: data)
            return decodedCounts
        } catch {
            print("Failed to decode dailyCounts: \(error)")
            return [:]
        }
    }

    // カウントデータの保存
    static func saveDailyCounts(_ dailyCounts: [String: Int]) -> Data? {
        do {
            let data = try JSONEncoder().encode(dailyCounts)
            return data
        } catch {
            print("Failed to encode dailyCounts: \(error)")
            return nil
        }
    }
}
