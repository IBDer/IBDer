import Foundation
import UserNotifications

/// One reminder the system should show.
struct ReminderRequest: Sendable, Equatable {
    let identifier: String
    let date: Date
    let title: String
    let body: String
}

/// Everything that knows about the notification centre is behind this, so the rules can be tested
/// without asking a simulator for permission.
protocol NotificationScheduling: Sendable {
    /// Returns whether the patient allowed notifications. False is not an error: the plan still exists.
    func requestAuthorization() async -> Bool
    /// Cancels every pending reminder whose identifier starts with the prefix, then schedules these.
    func replaceAll(prefix: String, with requests: [ReminderRequest]) async
    /// What is currently scheduled, for tests and for telling the patient the truth.
    func pending() async -> [ReminderRequest]
}

actor SystemNotificationScheduler: NotificationScheduling {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        await (try? center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func replaceAll(prefix: String, with requests: [ReminderRequest]) async {
        let existing = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(prefix) }
        center.removePendingNotificationRequests(withIdentifiers: existing)

        for request in requests where request.date > .now {
            let content = UNMutableNotificationContent()
            content.title = request.title
            content.body = request.body
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: request.date
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let notification = UNNotificationRequest(
                identifier: request.identifier,
                content: content,
                trigger: trigger
            )
            try? await center.add(notification)
        }
    }

    func pending() async -> [ReminderRequest] {
        await center.pendingNotificationRequests().compactMap { request in
            guard let trigger = request.trigger as? UNCalendarNotificationTrigger,
                  let date = Calendar.current.date(from: trigger.dateComponents)
            else { return nil }
            return ReminderRequest(
                identifier: request.identifier,
                date: date,
                title: request.content.title,
                body: request.content.body
            )
        }
    }
}

/// Used by previews, tests and `-inMemory` launches.
actor InMemoryNotificationScheduler: NotificationScheduling {
    private(set) var scheduled: [ReminderRequest] = []
    private(set) var authorizationRequests = 0
    var isAuthorized: Bool

    init(isAuthorized: Bool = true) {
        self.isAuthorized = isAuthorized
    }

    func requestAuthorization() async -> Bool {
        authorizationRequests += 1
        return isAuthorized
    }

    func replaceAll(prefix: String, with requests: [ReminderRequest]) async {
        scheduled.removeAll { $0.identifier.hasPrefix(prefix) }
        scheduled.append(contentsOf: requests)
    }

    func pending() async -> [ReminderRequest] {
        scheduled
    }
}
