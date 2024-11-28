import SwiftUI

struct DateCellView: View {
    let day: String
    let isToday: Bool
    let count: Int?
    let onTap: () -> Void
    let onLongPress: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(isToday ? Color.blue : Color.gray.opacity(0.2))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(8)
                .onTapGesture {
                    onTap()
                }
                .onLongPressGesture {
                    onLongPress()
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
