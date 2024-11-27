import SwiftUI

// カスタムボタンスタイルを定義
struct ButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.black)
            .cornerRadius(8)
    }
}
