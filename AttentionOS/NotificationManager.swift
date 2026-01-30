import Foundation
import UserNotifications
import SwiftData

enum NotificationSettings {
    static let globalEnabledKey = "notificationsEnabled"
}

final class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    func schedule(id: String, date: Date, title: String, body: String) async {
        let enabled = UserDefaults.standard.bool(forKey: NotificationSettings.globalEnabledKey)
        guard enabled else { return }
        let authorized = await requestAuthorizationIfNeeded()
        guard authorized else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        do {
            try await center.add(request)
        } catch {
            // Ignore scheduling failures for now.
        }
    }

    func cancel(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    func reschedule(id: String, date: Date, title: String, body: String) async {
        cancel(id: id)
        await schedule(id: id, date: date, title: title, body: body)
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}

protocol NotifiableItem {
    var nextReview: Date? { get }
    var notifyEnabled: Bool { get }
    var notificationKey: String { get }
    var notificationTitle: String { get }
    var notificationBody: String { get }
}

protocol MutableNotifiableItem: NotifiableItem, AnyObject {
    var nextReview: Date? { get set }
    var notifyEnabled: Bool { get set }
}

extension InboxItem: MutableNotifiableItem {
    var notificationKey: String {
        "Inbox:\(persistentModelID)"
    }

    var notificationTitle: String {
        thought.isEmpty ? "Inbox Review" : thought
    }

    var notificationBody: String {
        why.isEmpty ? "Scheduled review is due." : why
    }
}

extension Case: MutableNotifiableItem {
    var notificationKey: String {
        "Case:\(persistentModelID)"
    }

    var notificationTitle: String {
        title.isEmpty ? "Case Review" : title
    }

    var notificationBody: String {
        brief.isEmpty ? "Scheduled case review is due." : brief
    }
}

extension Attempt: MutableNotifiableItem {
    var notificationKey: String {
        "Attempt:\(persistentModelID)"
    }

    var notificationTitle: String {
        note.isEmpty ? "Attempt Review" : note
    }

    var notificationBody: String {
        outcome.isEmpty ? "Scheduled attempt review is due." : outcome
    }
}

func updateNotification(for item: NotifiableItem, globalEnabled: Bool) {
    let manager = NotificationManager.shared
    let id = item.notificationKey
    guard globalEnabled, item.notifyEnabled, let date = item.nextReview else {
        manager.cancel(id: id)
        return
    }
    let title = item.notificationTitle
    let body = item.notificationBody
    Task {
        await manager.reschedule(id: id, date: date, title: title, body: body)
    }
}

func syncNotification(for item: MutableNotifiableItem, globalEnabled: Bool) {
    item.notifyEnabled = item.nextReview != nil
    updateNotification(for: item, globalEnabled: globalEnabled)
}
