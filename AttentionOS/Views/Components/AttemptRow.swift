import SwiftUI

struct AttemptRow: View {
    let attempt: Attempt

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(attempt.note.isEmpty ? "Untitled Attempt" : attempt.note)
                .font(.headline)
            HStack(spacing: 12) {
                Text("State \(attempt.state.rawValue)")
                Text("Decision \(attempt.decision.rawValue)")
                if let nextReview = attempt.nextReview {
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
        AttemptRow(attempt: Attempt(note: "Draft outline", state: .active, decision: .doNow))
    }
    .modelContainer(PreviewContainer.shared)
}
