//
//  SparkNotificationService.swift
//  Spark
//
//  Purpose:
//  Local notification scheduling helpers.
//
//  Responsibilities:
//  • Schedules one-off and recurring UNUserNotificationCenter requests.
//

import Foundation
import UserNotifications

enum SparkNotificationService {
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        @unknown default:
            return false
        }
    }

    @discardableResult
    static func scheduleReminder(title: String, body: String, date: Date) async -> String? {
        guard date.timeIntervalSinceNow > 0 else { return nil }

        let identifier = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            return identifier
        } catch {
            return nil
        }
    }

    static func cancelReminder(id: String) async {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id])
    }

    static func cancelReminders(ids: [String]) async {
        guard !ids.isEmpty else { return }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ids)
    }

    @discardableResult
    static func scheduleDailyReminder(title: String, body: String, hour: Int, minute: Int) async -> String? {
        let identifier = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            return identifier
        } catch {
            return nil
        }
    }

    /// Weekday index where 0 = Sunday; converted to Calendar's 1-based weekday.
    @discardableResult
    static func scheduleWeeklyReminder(
        title: String,
        body: String,
        jsWeekday: Int,
        hour: Int,
        minute: Int
    ) async -> String? {
        let identifier = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = DateComponents()
        components.weekday = jsWeekday + 1
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            return identifier
        } catch {
            return nil
        }
    }

    /// Schedules a one-off timer completion notification with second-level accuracy.
    @discardableResult
    static func scheduleTimerFinish(at date: Date) async -> String? {
        let interval = date.timeIntervalSinceNow
        guard interval > 0 else { return nil }

        let identifier = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = "Time's up! 🎉"
        content.body = "Your timer finished. Great work — take a breath. 💗"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            return identifier
        } catch {
            return nil
        }
    }
}
