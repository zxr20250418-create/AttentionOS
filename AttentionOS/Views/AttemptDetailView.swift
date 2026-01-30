import SwiftUI
import SwiftData

struct AttemptDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(NotificationSettings.globalEnabledKey) private var notificationsEnabled = true
    @Bindable var attempt: Attempt
    @State private var isPresentingEdit = false
    @State private var isPresentingComplete = false
    @State private var isPresentingPause = false
    @State private var showActiveConflictAlert = false

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
            ToolbarItemGroup(placement: .bottomBar) {
                if attempt.state == .active {
                    Button("暂停") {
                        isPresentingPause = true
                    }
                }
                if attempt.state != .done {
                    Button("完成") {
                        isPresentingComplete = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isPresentingEdit = true
                }
            }
        }
        .sheet(isPresented: $isPresentingEdit) {
            NavigationStack {
                AttemptFormView(mode: .edit, initial: AttemptFormValues(attempt: attempt)) { values in
                    if values.state == .active, hasOtherActiveAttempt() {
                        showActiveConflictAlert = true
                        return
                    }
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
                    syncNotification(for: attempt, globalEnabled: notificationsEnabled)
                }
            }
        }
        .sheet(isPresented: $isPresentingComplete) {
            NavigationStack {
                AttemptCompletionView(
                    initial: AttemptCompletionValues(
                        decision: attempt.decision,
                        benefit: attempt.benefit,
                        friction: attempt.friction,
                        notesMarkdown: attempt.outcome
                    )
                ) { values in
                    attempt.state = .done
                    attempt.updatedAt = .now
                    attempt.decision = values.decision
                    attempt.benefit = values.benefit
                    attempt.friction = values.friction
                    attempt.outcome = values.notesMarkdown
                    attempt.nextReview = nil
                    attempt.notifyEnabled = false
                    try? modelContext.save()
                    syncNotification(for: attempt, globalEnabled: notificationsEnabled)
                }
            }
        }
        .sheet(isPresented: $isPresentingPause) {
            NavigationStack {
                AttemptPauseView(
                    initial: AttemptPauseValues(nextReview: attempt.nextReview ?? .now)
                ) { values in
                    attempt.state = .paused
                    attempt.updatedAt = .now
                    attempt.nextReview = values.nextReview
                    attempt.notifyEnabled = true
                    try? modelContext.save()
                    syncNotification(for: attempt, globalEnabled: notificationsEnabled)
                }
            }
        }
        .alert("已有进行中的 Attempt", isPresented: $showActiveConflictAlert) {
            Button("好", role: .cancel) { }
        } message: {
            Text("同一时间只能一个 Attempt 处于 active。请先完成或暂停当前进行中的 Attempt。")
        }
    }

    private func hasOtherActiveAttempt() -> Bool {
        let descriptor = FetchDescriptor<Attempt>()
        guard let attempts = try? modelContext.fetch(descriptor) else { return false }
        return attempts.contains { $0.state == .active && $0.persistentModelID != attempt.persistentModelID }
    }
}

#Preview {
    NavigationStack {
        AttemptDetailView(attempt: Attempt(note: "Draft outline", outcome: "Outline drafted", importance: 7, urgency: 6))
    }
    .modelContainer(PreviewContainer.shared)
}
