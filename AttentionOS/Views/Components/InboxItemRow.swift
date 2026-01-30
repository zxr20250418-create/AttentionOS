import SwiftUI
import SwiftData

private struct ScheduleOption: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
}

struct InboxItemRow: View {
    let item: InboxItem
    @Environment(\.modelContext) private var modelContext
    @AppStorage(NotificationSettings.globalEnabledKey) private var notificationsEnabled = true
    @State private var showScheduleOptions = false

    private var scheduleOptions: [ScheduleOption] {
        let now = Date()
        let calendar = Calendar.current
        let tonight = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 20, minute: 0),
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? now
        let tomorrowBase = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        let tomorrowMorning = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrowBase) ?? tomorrowBase
        let threeDaysBase = calendar.date(byAdding: .day, value: 3, to: now) ?? now
        let threeDaysLater = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: threeDaysBase) ?? threeDaysBase
        let nextMondayStart = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        let nextMonday = calendar.nextDate(
            after: nextMondayStart,
            matching: DateComponents(hour: 9, minute: 0, weekday: 2),
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? nextMondayStart
        return [
            ScheduleOption(title: "今晚", date: tonight),
            ScheduleOption(title: "明早", date: tomorrowMorning),
            ScheduleOption(title: "3天后", date: threeDaysLater),
            ScheduleOption(title: "下周一", date: nextMonday)
        ]
    }

    private func applyDoNow() {
        item.decision = .doNow
        item.state = .active
        item.nextReview = nil
        item.notifyEnabled = false
        item.manual = true
        item.updatedAt = .now
        persistChanges()
    }

    private func applySchedule(date: Date) {
        item.decision = .schedule
        item.nextReview = date
        item.notifyEnabled = true
        item.manual = true
        item.updatedAt = .now
        persistChanges()
    }

    private func applyDrop() {
        item.decision = .drop
        item.state = .done
        item.nextReview = nil
        item.notifyEnabled = false
        item.manual = true
        item.updatedAt = .now
        persistChanges()
    }

    private func persistChanges() {
        try? modelContext.save()
        syncNotification(for: item, globalEnabled: notificationsEnabled)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.thought)
                .font(.headline)
            if !item.why.isEmpty {
                Text(item.why)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                Text("I \(item.importance)")
                Text("U \(item.urgency)")
                if let nextReview = item.nextReview {
                    Text(nextReview, style: .date)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button("Do Now") {
                applyDoNow()
            }
            Button("Schedule…") {
                showScheduleOptions = true
            }
            Button("Drop", role: .destructive) {
                applyDrop()
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button("Schedule") {
                showScheduleOptions = true
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Do Now") {
                applyDoNow()
            }
            .tint(.green)
            Button("Drop", role: .destructive) {
                applyDrop()
            }
        }
        .confirmationDialog("安排复盘时间", isPresented: $showScheduleOptions, titleVisibility: .visible) {
            ForEach(scheduleOptions) { option in
                Button(option.title) {
                    applySchedule(date: option.date)
                }
            }
            Button("取消", role: .cancel) {}
        }
    }
}

#Preview {
    List {
        InboxItemRow(item: InboxItem(thought: "Draft the update", why: "Team sync", importance: 6, urgency: 4))
    }
    .modelContainer(PreviewContainer.shared)
}
