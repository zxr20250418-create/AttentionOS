import SwiftUI
import SwiftData

struct CaseDetailView: View {
    @Bindable var caseItem: Case

    var body: some View {
        Form {
            Section("Overview") {
                Text(caseItem.title)
                    .font(.title3)
                if !caseItem.details.isEmpty {
                    Text(caseItem.details)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Signals") {
                LabeledContent("Importance", value: "\(caseItem.importance)")
                LabeledContent("Urgency", value: "\(caseItem.urgency)")
                LabeledContent("State", value: caseItem.state.rawValue)
                LabeledContent("Decision", value: caseItem.decision.rawValue)
            }

            Section("Next Review") {
                if let nextReview = caseItem.nextReview {
                    Text(nextReview, style: .date)
                } else {
                    Text("Not scheduled")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Notify", value: caseItem.notifyEnabled ? "On" : "Off")
                LabeledContent("Manual", value: caseItem.manual ? "Yes" : "No")
            }
        }
        .navigationTitle("Case")
    }
}

#Preview {
    NavigationStack {
        CaseDetailView(caseItem: Case(title: "Launch v0.1", details: "Scaffold app", importance: 9, urgency: 8))
    }
    .modelContainer(PreviewContainer.shared)
}
