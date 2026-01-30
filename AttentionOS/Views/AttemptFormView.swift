import SwiftUI

struct AttemptFormValues {
    var note: String
    var outcome: String
    var importance: Int
    var urgency: Int
    var decision: Decision
    var benefit: Double
    var friction: Double
    var state: ItemState
    var nextReview: Date?

    static var empty: AttemptFormValues {
        AttemptFormValues(
            note: "",
            outcome: "",
            importance: 0,
            urgency: 0,
            decision: .undecided,
            benefit: 0,
            friction: 0,
            state: .active,
            nextReview: nil
        )
    }

    init(
        note: String,
        outcome: String,
        importance: Int,
        urgency: Int,
        decision: Decision,
        benefit: Double,
        friction: Double,
        state: ItemState,
        nextReview: Date?
    ) {
        self.note = note
        self.outcome = outcome
        self.importance = importance
        self.urgency = urgency
        self.decision = decision
        self.benefit = benefit
        self.friction = friction
        self.state = state
        self.nextReview = nextReview
    }

    init(attempt: Attempt) {
        self.note = attempt.note
        self.outcome = attempt.outcome
        self.importance = attempt.importance
        self.urgency = attempt.urgency
        self.decision = attempt.decision
        self.benefit = attempt.benefit
        self.friction = attempt.friction
        self.state = attempt.state
        self.nextReview = attempt.nextReview
    }
}

enum AttemptFormMode {
    case new
    case edit

    var title: String {
        switch self {
        case .new:
            return "New Attempt"
        case .edit:
            return "Edit Attempt"
        }
    }

    var actionTitle: String {
        switch self {
        case .new:
            return "Create"
        case .edit:
            return "Save"
        }
    }
}

struct AttemptFormView: View {
    let mode: AttemptFormMode
    let onSave: (AttemptFormValues) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var noteText: String
    @State private var outcomeText: String
    @State private var importance: Int
    @State private var urgency: Int
    @State private var decision: Decision
    @State private var benefit: Double
    @State private var friction: Double
    @State private var state: ItemState
    @State private var hasNextReview: Bool
    @State private var nextReview: Date

    init(mode: AttemptFormMode, initial: AttemptFormValues, onSave: @escaping (AttemptFormValues) -> Void) {
        self.mode = mode
        self.onSave = onSave
        _noteText = State(initialValue: initial.note)
        _outcomeText = State(initialValue: initial.outcome)
        _importance = State(initialValue: initial.importance)
        _urgency = State(initialValue: initial.urgency)
        _decision = State(initialValue: initial.decision)
        _benefit = State(initialValue: initial.benefit)
        _friction = State(initialValue: initial.friction)
        _state = State(initialValue: initial.state)
        _hasNextReview = State(initialValue: initial.nextReview != nil)
        _nextReview = State(initialValue: initial.nextReview ?? .now)
    }

    var body: some View {
        Form {
            Section("Basics") {
                TextField("Note", text: $noteText, axis: .vertical)
            }

            Section("Outcome (optional)") {
                TextField("Outcome", text: $outcomeText, axis: .vertical)
            }

            Section("Signals") {
                Stepper("Importance \(importance)", value: $importance, in: 0...10)
                Stepper("Urgency \(urgency)", value: $urgency, in: 0...10)
                Picker("Decision", selection: $decision) {
                    ForEach(Decision.allCases, id: \.self) { decision in
                        Text(decision.rawValue)
                    }
                }
                Picker("State", selection: $state) {
                    ForEach(ItemState.allCases, id: \.self) { state in
                        Text(state.rawValue)
                    }
                }
                Stepper(value: $benefit, in: 0...10, step: 0.5) {
                    Text("Benefit \(benefit, specifier: "%.1f")")
                }
                Stepper(value: $friction, in: 0...10, step: 0.5) {
                    Text("Friction \(friction, specifier: "%.1f")")
                }
            }

            Section("Next Review") {
                Toggle("Schedule next review", isOn: $hasNextReview)
                if hasNextReview {
                    DatePicker("Date", selection: $nextReview, displayedComponents: .date)
                }
            }
        }
        .navigationTitle(mode.title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(mode.actionTitle) {
                    save()
                }
            }
        }
    }

    private func save() {
        let trimmedNote = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        let values = AttemptFormValues(
            note: trimmedNote,
            outcome: outcomeText.trimmingCharacters(in: .whitespacesAndNewlines),
            importance: importance,
            urgency: urgency,
            decision: decision,
            benefit: benefit,
            friction: friction,
            state: state,
            nextReview: hasNextReview ? nextReview : nil
        )
        onSave(values)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AttemptFormView(mode: .new, initial: .empty) { _ in }
    }
    .modelContainer(PreviewContainer.shared)
}
