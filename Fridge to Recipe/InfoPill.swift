import SwiftUI

struct InfoPill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
        .foregroundColor(.secondary)
    }
} 