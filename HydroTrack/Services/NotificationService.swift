import Foundation
import UserNotifications

// MARK: - NotificationService

/// Schedules dynamic hydration reminders within the user's notification window.
///
/// Strategy:
/// - Divide the notification window into 2-hour slots.
/// - At each slot, if the user is behind their expected pace, a notification fires.
/// - Every time the user logs water (or the app opens), all pending notifications are
///   cleared and a fresh schedule is computed so the user is never nagged if on track.
final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Schedule

    /// Call this after every water log and on app foreground.
    func rescheduleNotifications(for profile: UserProfile, todayOz: Double) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let calendar = Calendar.current
        let now = Date()
        let currentMinuteOfDay = calendar.component(.hour, from: now) * 60
                                + calendar.component(.minute, from: now)

        let startMinute = profile.notificationStartHour * 60
        let endMinute   = profile.notificationEndHour   * 60

        // Build 2-hour check slots within the window
        var slots: [Int] = []
        var t = startMinute
        while t <= endMinute {
            slots.append(t)
            t += 120
        }

        // Only schedule future slots (with a 30-min grace to avoid instant-fire)
        let futureSlots = slots.filter { $0 > currentMinuteOfDay + 30 }
        let currentProgress = profile.dailyGoalOz > 0 ? todayOz / profile.dailyGoalOz : 0

        for slot in futureSlots {
            let expectedProgress = expectedPace(
                atMinute: slot,
                startMinute: startMinute,
                endMinute: endMinute
            )
            // Only queue a notification if the user is currently > 10% behind pace
            if currentProgress < expectedProgress - 0.10 {
                schedule(
                    atHour: slot / 60,
                    minute: slot % 60,
                    name: profile.name,
                    currentOz: todayOz,
                    goalOz: profile.dailyGoalOz
                )
            }
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Private helpers

    private func expectedPace(atMinute minute: Int, startMinute: Int, endMinute: Int) -> Double {
        let window = Double(endMinute - startMinute)
        guard window > 0 else { return 1.0 }
        let elapsed = Double(max(0, minute - startMinute))
        return min(elapsed / window, 1.0)
    }

    private func schedule(atHour hour: Int, minute: Int, name: String, currentOz: Double, goalOz: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Hydration check, \(name)! 💧"
        content.body  = motivationalMessage(currentOz: currentOz, goalOz: goalOz)
        content.sound = .default

        var comps = DateComponents()
        comps.hour   = hour
        comps.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(
            identifier: "hydro_\(hour)_\(minute)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func motivationalMessage(currentOz: Double, goalOz: Double) -> String {
        let pct       = Int((currentOz / goalOz) * 100)
        let remaining = max(0, goalOz - currentOz)

        let messages = [
            "You're at \(pct)% — grab that bottle and keep the streak going!",
            "Still \(Int(remaining)) oz to go. Your body is counting on you!",
            "Hydration check! You're \(pct)% there. Let's keep it flowing!",
            "Water is life — you've had \(Int(currentOz)) oz so far. Keep it up!",
            "Every sip counts! \(Int(remaining)) oz left to crush your daily goal.",
            "Don't forget to drink up! You're \(pct)% hydrated today.",
            "Your future self will thank you — drink some water now! 🌊",
        ]
        return messages[Int.random(in: 0..<messages.count)]
    }
}
