import SwiftUI

struct AttemptCompletionValues {
    var decision: Decision
    var benefit: Double
    var friction: Double
    var notesMarkdown: String
}

struct AttemptCompletionView: View {
    let initial: AttemptCompletionValues
    let onComplete: (AttemptCompletionValues) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var decision: Decision
    @State private var benefit: Double
    @State private var friction: Double
    @State private var notesMarkdown: String

    init(initial: AttemptCompletionValues, onComplete: @escaping (AttemptCompletionValues) -> Void) {
        self.initial = initial
        self.onComplete = onComplete
        _decision = State(initialValue: initial.decision)
        _benefit = State(initialValue: initial.benefit)
        _friction = State(initialValue: initial.friction)
        _notesMarkdown = State(initialValue: initial.notesMarkdown)
    }

    var body: some View {
        Form {
            Section("Decision") {
                Picker("Decision", selection: $decision) {
                    ForEach(Decision.allCases, id: \.self) { decision in
                        Text(decision.rawValue)
                            .tag(decision)
                    }
                }
            }

            Section("Signals") {
                Stepper(value: $benefit, in: 0...10, step: 0.5) {
                    Text("Benefit \(benefit, specifier: "%.1f")")
                }
                Stepper(value: $friction, in: 0...10, step: 0.5) {
                    Text("Friction \(friction, specifier: "%.1f")")
                }
            }

            Section("Notes (Markdown)") {
                TextEditor(text: $notesMarkdown)
                    .frame(minHeight: 160)
            }

            if !validationErrors.isEmpty {
                Section {
                    ForEach(validationErrors, id: \.self) { error in
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .navigationTitle("完成 Attempt")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") { complete() }
                    .disabled(!isValid)
            }
        }
    }

    private var isValid: Bool {
        validationErrors.isEmpty
    }

    private var validationErrors: [String] {
        var errors: [String] = []
        if decision == .undecided {
            errors.append("请选择 decision（不能是 undecided）。")
        }
        if !hasAtLeastOneNonEmptyLine(notesMarkdown) {
            errors.append("notesMarkdown 至少需要 1 行内容。")
        }
        return errors
    }

    private func hasAtLeastOneNonEmptyLine(_ text: String) -> Bool {
        let lines = text.split(whereSeparator: \.isNewline)
        return lines.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private func complete() {
        let values = AttemptCompletionValues(
            decision: decision,
            benefit: benefit,
            friction: friction,
            notesMarkdown: notesMarkdown.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        onComplete(values)
        dismiss()
    }
}

struct AttemptPauseValues {
    var nextReview: Date
}

struct AttemptPauseView: View {
    let initial: AttemptPauseValues
    let onPause: (AttemptPauseValues) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var nextReview: Date

    init(initial: AttemptPauseValues, onPause: @escaping (AttemptPauseValues) -> Void) {
        self.initial = initial
        self.onPause = onPause
        _nextReview = State(initialValue: initial.nextReview)
    }

    var body: some View {
        Form {
            Section("Next Review") {
                DatePicker("Date", selection: $nextReview, displayedComponents: .date)
            }
        }
        .navigationTitle("暂停 Attempt")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("暂停") { pause() }
            }
        }
    }

    private func pause() {
        onPause(AttemptPauseValues(nextReview: nextReview))
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AttemptCompletionView(
            initial: AttemptCompletionValues(decision: .doNow, benefit: 6.5, friction: 3, notesMarkdown: "Done.\n- Learned X")
        ) { _ in }
    }
}

