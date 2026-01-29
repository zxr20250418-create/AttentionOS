import SwiftUI

struct CaseRow: View {
    let caseItem: Case

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(caseItem.title.isEmpty ? "Untitled Case" : caseItem.title)
                .font(.headline)
            if !caseItem.brief.isEmpty {
                Text(caseItem.brief)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if !caseItem.details.isEmpty {
                Text(caseItem.details)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                Text("I \(caseItem.importance)")
                Text("U \(caseItem.urgency)")
                if let nextReview = caseItem.nextReview {
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
        CaseRow(caseItem: Case(title: "Launch v0.1", details: "Scaffold core flow", importance: 8, urgency: 6))
    }
    .modelContainer(PreviewContainer.shared)
}
