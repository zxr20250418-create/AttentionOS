import SwiftUI

struct InboxItemRow: View {
    let item: InboxItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.thought)
                .font(.headline)
            if !item.why.isEmpty {
                Text(item.why)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                Text("I \(item.importance)")
                Text("U \(item.urgency)")
                if let nextReview = item.nextReview {
                    Text(nextReview, style: .date)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        InboxItemRow(item: InboxItem(thought: "Draft the update", why: "Team sync", importance: 6, urgency: 4))
    }
    .modelContainer(PreviewContainer.shared)
}
