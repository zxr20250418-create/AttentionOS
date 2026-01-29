import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage(NotificationSettings.globalEnabledKey) private var notificationsEnabled = true
    @Query private var inboxItems: [InboxItem]
    @Query private var cases: [Case]
    @Query private var attempts: [Attempt]

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Enable notifications", isOn: $notificationsEnabled)
                Text("Notifications are scheduled for items with a next review date.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .onChange(of: notificationsEnabled) { _, isOn in
            handleNotificationsToggle(isOn: isOn)
        }
        .onAppear {
            if notificationsEnabled {
                Task {
                    _ = await NotificationManager.shared.requestAuthorizationIfNeeded()
                }
            }
        }
    }

    private func handleNotificationsToggle(isOn: Bool) {
        if isOn {
            Task {
                _ = await NotificationManager.shared.requestAuthorizationIfNeeded()
                scheduleAll()
            }
        } else {
            NotificationManager.shared.cancelAll()
        }
    }

    private func scheduleAll() {
        for item in inboxItems {
            updateNotification(for: item, globalEnabled: true)
        }
        for caseItem in cases {
            updateNotification(for: caseItem, globalEnabled: true)
        }
        for attempt in attempts {
            updateNotification(for: attempt, globalEnabled: true)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(PreviewContainer.shared)
}
