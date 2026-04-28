import Foundation
import UserNotifications

struct NotificationManager {
    private let center = UNUserNotificationCenter.current()

    func requestPermission() async {
        _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func schedulePrayerReminders(for days: [PrayerDay]) async {
        await clearPrayerReminders()

        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "dd.MM.yyyy HH:mm"

        for day in days {
            let prayers: [(String, String)] = [
                ("İmsak", day.imsak),
                ("Öğle", day.ogle),
                ("İkindi", day.ikindi),
                ("Akşam", day.aksam),
                ("Yatsı", day.yatsi)
            ]

            for (name, time) in prayers {
                guard let prayerDate = formatter.date(from: "\(day.miladiTarihKisa) \(time)") else { continue }
                guard let triggerDate = calendar.date(byAdding: .minute, value: -15, to: prayerDate), triggerDate > Date() else {
                    continue
                }

                let content = UNMutableNotificationContent()
                content.title = "\(name) namazına 15 dakika kaldı"
                content.body = "\(day.miladiTarihUzun ?? day.miladiTarihKisa) için hazırlık vakti."
                content.sound = .default

                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let id = "prayer.\(day.miladiTarihKisa).\(name)"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

                try? await center.add(request)
            }
        }
    }

    private func clearPrayerReminders() async {
        let requests = await pendingRequests()
        let ids = requests.map(\.identifier).filter { $0.hasPrefix("prayer.") }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func pendingRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }
}
