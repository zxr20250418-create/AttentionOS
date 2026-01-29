import Foundation
import SwiftData

@MainActor
enum PreviewContainer {
    static let shared: ModelContainer = {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(
                for: InboxItem.self,
                    Case.self,
                    Attempt.self,
                configurations: configuration
            )
            let context = container.mainContext
            context.insert(
                InboxItem(
                    thought: "Follow up with Alice",
                    why: "Project timeline",
                    importance: 7,
                    urgency: 6,
                    decision: .doNow,
                    nextReview: Date.now.addingTimeInterval(-3600)
                )
            )
            context.insert(
                InboxItem(
                    thought: "Plan Q2 roadmap",
                    why: "Strategy sync",
                    importance: 8,
                    urgency: 3,
                    decision: .schedule,
                    nextReview: Date.now.addingTimeInterval(86400 * 3)
                )
            )
            context.insert(
                Case(
                    title: "Launch AttentionOS v0.1",
                    brief: "Scaffold core flows",
                    details: "Scaffold core flows",
                    importance: 9,
                    urgency: 7,
                    decision: .doNow
                )
            )
            return container
        } catch {
            fatalError("Preview container failed: \(error)")
        }
    }()
}
