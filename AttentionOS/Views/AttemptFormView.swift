import SwiftUI

struct AttemptFormValues {
    var note: String
    var decision: Decision
    var benefit: Double
    var friction: Double
    var state: ItemState
    var nextReview: Date?

    static var empty: AttemptFormValues {
        AttemptFormValues(
            note: "",
            decision: .undecided,
            benefit: 0,
            friction: 0,
            state: .active,
            nextReview: nil
        )
    }
}

enum AttemptFormMode {
    case new

    var title: String {
        switch self {
        case .new:
            return "New Attempt"
        }
    }

    var actionTitle: String {
        switch self {
        case .new:
            return "Create"
        }
    }
}

struct AttemptFormView: View {
    let mode: AttemptFormMode
    let onSave: (AttemptFormValues) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var noteText: String
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
        _decision = State(initialValue: initial.decision)
        _benefit = State(initialValue: initial.benefit)
        _friction = State(initialValue: initial.friction)
        _state = State(initialValue: initial.state)
        _hasNextReview = State(initialValue: initial.nextReview != nil)
        _nextReview = State(initialValue: initial.nextReview ?? .now)
    }

    var body: some View {
        Form {
            Section("Notes (optional)") {
                TextField("Notes", text: $noteText, axis: .vertical)
            }

            Section("Signals") {
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
        let values = AttemptFormValues(
            note: noteText.trimmingCharacters(in: .whitespacesAndNewlines),
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
