import SwiftUI
import SwiftData

@main
struct AttentionOSApp: App {
    @State private var selection: AppTab = .review
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: InboxItem.self, Case.self, Attempt.self)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(selection: $selection)
        }
        .modelContainer(container)
    }
}

enum AppTab: Hashable {
    case capture
    case review
    case cases
}

struct RootTabView: View {
    @Binding var selection: AppTab

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                CaptureView()
            }
            .tabItem {
                Label("Capture", systemImage: "square.and.pencil")
            }
            .tag(AppTab.capture)

            NavigationStack {
                ReviewView()
            }
            .tabItem {
                Label("Review", systemImage: "checklist")
            }
            .tag(AppTab.review)

            NavigationStack {
                CasesView()
            }
            .tabItem {
                Label("Cases", systemImage: "tray.full")
            }
            .tag(AppTab.cases)
        }
    }
}

#Preview {
    RootTabView(selection: .constant(.review))
        .modelContainer(PreviewContainer.shared)
}
