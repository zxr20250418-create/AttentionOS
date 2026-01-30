import SwiftUI
import SwiftData

struct CaseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(NotificationSettings.globalEnabledKey) private var notificationsEnabled = true
    @Bindable var caseItem: Case
    @State private var isPresentingEdit = false
    @State private var isPresentingNewAttempt = false
    @State private var showActiveConflictAlert = false

    private var sortedAttempts: [Attempt] {
        caseItem.attempts.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        Form {
            Section("Overview") {
                Text(caseItem.title.isEmpty ? "Untitled Case" : caseItem.title)
                    .font(.title3)
                if !caseItem.brief.isEmpty {
                    Text(caseItem.brief)
                        .foregroundStyle(.secondary)
                }
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

            Section("Attempts") {
                Button("New Attempt") {
                    guard !hasAnyActiveAttempt() else {
                        showActiveConflictAlert = true
                        return
                    }
                    isPresentingNewAttempt = true
                }

                if sortedAttempts.isEmpty {
                    Text("No attempts yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedAttempts) { attempt in
                        NavigationLink {
                            AttemptDetailView(attempt: attempt)
                        } label: {
                            AttemptRow(attempt: attempt)
                        }
                    }
                }
            }
        }
        .navigationTitle("Case")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isPresentingEdit = true
                }
            }
        }
        .sheet(isPresented: $isPresentingEdit) {
            NavigationStack {
                CaseFormView(mode: .edit, initial: CaseFormValues(caseItem: caseItem)) { values in
                    caseItem.title = values.title
                    caseItem.brief = values.brief
                    caseItem.details = values.details
                    caseItem.importance = values.importance
                    caseItem.urgency = values.urgency
                    caseItem.decision = values.decision
                    caseItem.nextReview = values.nextReview
                    caseItem.notifyEnabled = values.nextReview != nil
                    caseItem.updatedAt = .now
                    try? modelContext.save()
                    updateNotification(for: caseItem, globalEnabled: notificationsEnabled)
                }
            }
        }
        .alert("已有进行中的 Attempt", isPresented: $showActiveConflictAlert) {
            Button("好", role: .cancel) { }
        } message: {
            Text("同一时间只能一个 Attempt 处于 active。请先完成或暂停当前进行中的 Attempt。")
        }
        .sheet(isPresented: $isPresentingNewAttempt) {
            NavigationStack {
                AttemptFormView(mode: .new, initial: .empty) { values in
                    let trimmedNote = values.note.trimmingCharacters(in: .whitespacesAndNewlines)
                    let notifyEnabled = values.nextReview != nil
                    let attempt = Attempt(
                        note: trimmedNote,
                        outcome: values.outcome,
                        importance: values.importance,
                        urgency: values.urgency,
                        state: values.state,
                        decision: values.decision,
                        benefit: values.benefit,
                        friction: values.friction,
                        nextReview: values.nextReview,
                        notifyEnabled: notifyEnabled
                    )
                    caseItem.attempts.append(attempt)
                    modelContext.insert(attempt)
                    try? modelContext.save()
                    updateNotification(for: attempt, globalEnabled: notificationsEnabled)
                }
            }
        }
    }

    private func hasAnyActiveAttempt() -> Bool {
        let descriptor = FetchDescriptor<Attempt>()
        guard let attempts = try? modelContext.fetch(descriptor) else { return false }
        return attempts.contains { $0.state == .active }
    }
}

#Preview {
    NavigationStack {
        CaseDetailView(caseItem: Case(title: "Launch v0.1", brief: "Scaffold core flow", details: "Scaffold app", importance: 9, urgency: 8))
    }
    .modelContainer(PreviewContainer.shared)
}
