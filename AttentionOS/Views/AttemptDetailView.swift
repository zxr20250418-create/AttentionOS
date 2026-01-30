import SwiftUI
import SwiftData

struct AttemptDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(NotificationSettings.globalEnabledKey) private var notificationsEnabled = true
    @Bindable var attempt: Attempt
    @State private var isPresentingEdit = false

    var body: some View {
        Form {
            Section("Overview") {
                Text(attempt.note.isEmpty ? "Untitled Attempt" : attempt.note)
                    .font(.title3)
                LabeledContent("Outcome") {
                    Text(attempt.outcome.isEmpty ? "—" : attempt.outcome)
                        .foregroundStyle(attempt.outcome.isEmpty ? .secondary : .primary)
                }
            }

            Section("Signals") {
                LabeledContent("Importance", value: "\(attempt.importance)")
                LabeledContent("Urgency", value: "\(attempt.urgency)")
                LabeledContent("State", value: attempt.state.rawValue)
                LabeledContent("Decision", value: attempt.decision.rawValue)
                LabeledContent("Benefit", value: String(format: "%.1f", attempt.benefit))
                LabeledContent("Friction", value: String(format: "%.1f", attempt.friction))
            }

            Section("Next Review") {
                if let nextReview = attempt.nextReview {
                    Text(nextReview, style: .date)
                } else {
                    Text("Not scheduled")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Meta") {
                LabeledContent("Updated") {
                    Text(attempt.updatedAt, format: .dateTime.year().month().day().hour().minute())
                }
            }
        }
        .navigationTitle("Attempt")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isPresentingEdit = true
                }
            }
        }
        .sheet(isPresented: $isPresentingEdit) {
            NavigationStack {
                AttemptFormView(mode: .edit, initial: AttemptFormValues(attempt: attempt)) { values in
                    attempt.note = values.note
                    attempt.outcome = values.outcome
                    attempt.importance = values.importance
                    attempt.urgency = values.urgency
                    attempt.state = values.state
                    attempt.decision = values.decision
                    attempt.benefit = values.benefit
                    attempt.friction = values.friction
                    attempt.nextReview = values.nextReview
                    attempt.notifyEnabled = values.nextReview != nil
                    attempt.updatedAt = .now
                    try? modelContext.save()
                    updateNotification(for: attempt, globalEnabled: notificationsEnabled)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AttemptDetailView(attempt: Attempt(note: "Draft outline", outcome: "Outline drafted", importance: 7, urgency: 6))
    }
    .modelContainer(PreviewContainer.shared)
}
