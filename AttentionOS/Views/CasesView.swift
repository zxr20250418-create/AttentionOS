import SwiftUI
import SwiftData

struct CasesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Case.createdAt, order: .reverse) private var cases: [Case]
    @State private var isPresentingNewCase = false

    var body: some View {
        List {
            if cases.isEmpty {
                ContentUnavailableView(
                    "No Cases Yet",
                    systemImage: "tray",
                    description: Text("Captured cases will appear here.")
                )
            } else {
                ForEach(cases) { caseItem in
                    NavigationLink {
                        CaseDetailView(caseItem: caseItem)
                    } label: {
                        CaseRow(caseItem: caseItem)
                    }
                }
            }
        }
        .navigationTitle("Cases")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingNewCase = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingNewCase) {
            NavigationStack {
                CaseFormView(mode: .new, initial: .empty) { values in
                    let newCase = Case(
                        title: values.title,
                        brief: values.brief,
                        details: values.details,
                        importance: values.importance,
                        urgency: values.urgency,
                        decision: values.decision,
                        nextReview: values.nextReview,
                        notifyEnabled: false,
                        manual: true,
                        createdAt: .now,
                        updatedAt: .now
                    )
                    modelContext.insert(newCase)
                    try? modelContext.save()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CasesView()
    }
    .modelContainer(PreviewContainer.shared)
}
