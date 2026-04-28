import Foundation

struct PrayerCache {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let selection = "prayer.selection"
        static let prayerDays = "prayer.days"
        static let lastRefresh = "prayer.lastRefresh"
    }

    func saveSelection(_ selection: PrayerSelection) {
        if let data = try? JSONEncoder().encode(selection) {
            defaults.set(data, forKey: Keys.selection)
        }
    }

    func loadSelection() -> PrayerSelection? {
        guard let data = defaults.data(forKey: Keys.selection) else { return nil }
        return try? JSONDecoder().decode(PrayerSelection.self, from: data)
    }

    func savePrayerDays(_ days: [PrayerDay]) {
        if let data = try? JSONEncoder().encode(days) {
            defaults.set(data, forKey: Keys.prayerDays)
            defaults.set(Date(), forKey: Keys.lastRefresh)
        }
    }

    func loadPrayerDays() -> [PrayerDay] {
        guard let data = defaults.data(forKey: Keys.prayerDays),
              let decoded = try? JSONDecoder().decode([PrayerDay].self, from: data) else {
            return []
        }
        return decoded
    }

    func lastRefreshDate() -> Date? {
        defaults.object(forKey: Keys.lastRefresh) as? Date
    }
}
