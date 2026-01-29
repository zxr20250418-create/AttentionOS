import SwiftUI
import SwiftData

struct CasesView: View {
    @Query(sort: \Case.createdAt, order: .reverse) private var cases: [Case]

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
    }
}

#Preview {
    NavigationStack {
        CasesView()
    }
    .modelContainer(PreviewContainer.shared)
}
