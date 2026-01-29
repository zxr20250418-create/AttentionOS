import SwiftUI

struct CaseFormValues {
    var title: String
    var brief: String
    var details: String
    var importance: Int
    var urgency: Int
    var decision: Decision
    var nextReview: Date?

    static var empty: CaseFormValues {
        CaseFormValues(
            title: "",
            brief: "",
            details: "",
            importance: 0,
            urgency: 0,
            decision: .undecided,
            nextReview: nil
        )
    }

    init(caseItem: Case) {
        self.title = caseItem.title
        self.brief = caseItem.brief
        self.details = caseItem.details
        self.importance = caseItem.importance
        self.urgency = caseItem.urgency
        self.decision = caseItem.decision
        self.nextReview = caseItem.nextReview
    }
}

enum CaseFormMode {
    case new
    case edit

    var title: String {
        switch self {
        case .new:
            return "New Case"
        case .edit:
            return "Edit Case"
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

struct CaseFormView: View {
    let mode: CaseFormMode
    let onSave: (CaseFormValues) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var titleText: String
    @State private var briefText: String
    @State private var detailsText: String
    @State private var importance: Int
    @State private var urgency: Int
    @State private var decision: Decision
    @State private var hasNextReview: Bool
    @State private var nextReview: Date

    init(mode: CaseFormMode, initial: CaseFormValues, onSave: @escaping (CaseFormValues) -> Void) {
        self.mode = mode
        self.onSave = onSave
        _titleText = State(initialValue: initial.title)
        _briefText = State(initialValue: initial.brief)
        _detailsText = State(initialValue: initial.details)
        _importance = State(initialValue: initial.importance)
        _urgency = State(initialValue: initial.urgency)
        _decision = State(initialValue: initial.decision)
        _hasNextReview = State(initialValue: initial.nextReview != nil)
        _nextReview = State(initialValue: initial.nextReview ?? .now)
    }

    var body: some View {
        Form {
            Section("Basics") {
                TextField("Title", text: $titleText, axis: .vertical)
            }

            Section("Brief (optional)") {
                TextField("Short summary", text: $briefText, axis: .vertical)
            }

            Section("Details (optional)") {
                TextField("Notes", text: $detailsText, axis: .vertical)
            }

            Section("Signals") {
                Stepper("Importance \(importance)", value: $importance, in: 0...10)
                Stepper("Urgency \(urgency)", value: $urgency, in: 0...10)
                Picker("Decision", selection: $decision) {
                    ForEach(Decision.allCases, id: \.self) { decision in
                        Text(decision.rawValue)
                    }
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
        let trimmedTitle = titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        let values = CaseFormValues(
            title: trimmedTitle,
            brief: briefText.trimmingCharacters(in: .whitespacesAndNewlines),
            details: detailsText.trimmingCharacters(in: .whitespacesAndNewlines),
            importance: importance,
            urgency: urgency,
            decision: decision,
            nextReview: hasNextReview ? nextReview : nil
        )
        onSave(values)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        CaseFormView(mode: .new, initial: .empty) { _ in }
    }
    .modelContainer(PreviewContainer.shared)
}
