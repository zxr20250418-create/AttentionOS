import SwiftUI
import SwiftData

struct ReviewView: View {
    @Query(sort: \InboxItem.createdAt, order: .reverse) private var items: [InboxItem]

    private var dueItems: [InboxItem] {
        let now = Date()
        return items.filter { item in
            guard let nextReview = item.nextReview else { return false }
            return nextReview <= now
        }
    }

    private var inboxItems: [InboxItem] {
        items.filter { item in
            item.state == .inbox && item.decision == .undecided && item.nextReview == nil
        }
    }

    private var doNowItems: [InboxItem] {
        items.filter { item in
            item.decision == .doNow && item.state != .done
        }
    }

    private var scheduleItems: [InboxItem] {
        let now = Date()
        return items.filter { item in
            guard let nextReview = item.nextReview else { return false }
            return item.decision == .schedule && item.state != .done && nextReview > now
        }
    }

    var body: some View {
        List {
            Section("Due") {
                if dueItems.isEmpty {
                    Text("Nothing due right now")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(dueItems) { item in
                        InboxItemRow(item: item)
                    }
                }
            }

            Section("Inbox") {
                if inboxItems.isEmpty {
                    Text("Inbox is clear")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(inboxItems) { item in
                        InboxItemRow(item: item)
                    }
                }
            }

            Section("Do Now") {
                if doNowItems.isEmpty {
                    Text("No immediate actions")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(doNowItems) { item in
                        InboxItemRow(item: item)
                    }
                }
            }

            Section("Schedule") {
                if scheduleItems.isEmpty {
                    Text("Nothing scheduled yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(scheduleItems) { item in
                        InboxItemRow(item: item)
                    }
                }
            }
        }
        .navigationTitle("Review")
    }
}

#Preview {
    NavigationStack {
        ReviewView()
    }
    .modelContainer(PreviewContainer.shared)
}
