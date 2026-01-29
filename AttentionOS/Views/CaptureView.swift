import SwiftUI
import SwiftData

struct CaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var thought = ""
    @State private var why = ""
    @FocusState private var focusThought: Bool

    private var trimmedThought: String {
        thought.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedWhy: String {
        why.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Form {
            Section("Idea") {
                TextField("What's on your mind?", text: $thought, axis: .vertical)
                    .focused($focusThought)
            }

            Section("Why (optional)") {
                TextField("Why does it matter?", text: $why, axis: .vertical)
            }

            Section {
                Button("Save to Inbox") {
                    save()
                }
                .disabled(trimmedThought.isEmpty)
            }
        }
        .navigationTitle("Capture")
        .onAppear {
            focusThought = true
        }
    }

    private func save() {
        let idea = trimmedThought
        guard !idea.isEmpty else { return }
        let item = InboxItem(
            thought: idea,
            why: trimmedWhy,
            importance: 5,
            urgency: 3,
            state: .inbox,
            decision: .undecided,
            benefit: 0,
            friction: 0,
            nextReview: nil,
            notifyEnabled: false,
            manual: true
        )
        modelContext.insert(item)
        try? modelContext.save()
        thought = ""
        why = ""
        focusThought = true
    }
}

#Preview {
    NavigationStack {
        CaptureView()
    }
    .modelContainer(PreviewContainer.shared)
}
