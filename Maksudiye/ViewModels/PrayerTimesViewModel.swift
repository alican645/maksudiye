import Foundation
import Combine
@MainActor
final class PrayerTimesViewModel: ObservableObject {
    @Published var cities: [PrayerCity] = []
    @Published var districts: [PrayerDistrict] = []
    @Published var selectedCity: PrayerCity?
    @Published var selectedDistrict: PrayerDistrict?
    @Published var prayerDays: [PrayerDay] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showLocationPicker = false
    @Published private var now = Date()

    private let apiService = PrayerAPIService()
    private let cache = PrayerCache()
    private let notificationManager = NotificationManager()
    private var timer: Timer?

    func bootstrap() async {
        startClock()
        await notificationManager.requestPermission()

        if let selection = cache.loadSelection() {
            selectedCity = selection.city
            selectedDistrict = selection.district
            prayerDays = cache.loadPrayerDays()
            await fetchDistrictsIfNeeded(for: selection.city)
            await refreshIfNeeded()
        } else {
            showLocationPicker = true
            await loadCities()
        }
    }

    func loadCities() async {
        isLoading = true
        defer { isLoading = false }
        do {
            cities = try await apiService.fetchCities()
            errorMessage = nil
        } catch {
            errorMessage = "Şehirler alınamadı. Lütfen tekrar deneyin."
        }
    }

    func fetchDistrictsIfNeeded(for city: PrayerCity) async {
        if selectedCity?.id != city.id {
            selectedDistrict = nil
        }
        selectedCity = city

        do {
            districts = try await apiService.fetchDistricts(cityID: city.sehirID)
            errorMessage = nil
        } catch {
            errorMessage = "İlçeler alınamadı."
        }
    }

    func saveSelectionAndLoad() async {
        guard let selectedCity, let selectedDistrict else { return }
        cache.saveSelection(.init(city: selectedCity, district: selectedDistrict))
        showLocationPicker = false
        await forceRefresh()
    }

    func refreshIfNeeded() async {
        guard let lastRefresh = cache.lastRefreshDate(),
              Calendar.current.isDate(lastRefresh, inSameDayAs: Date()) else {
            await forceRefresh()
            return
        }

        if prayerDays.isEmpty {
            prayerDays = cache.loadPrayerDays()
        }
    }

    func forceRefresh() async {
        guard let districtID = selectedDistrict?.ilceID else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let allDays = try await apiService.fetchPrayerTimes(districtID: districtID)
            let fresh = filterThreeDays(from: allDays)
            prayerDays = fresh
            cache.savePrayerDays(fresh)
            await notificationManager.schedulePrayerReminders(for: fresh)
            errorMessage = nil
        } catch {
            errorMessage = "Namaz vakitleri alınamadı."
        }
    }

    var locationTitle: String {
        if let district = selectedDistrict?.ilceAdi, let city = selectedCity?.sehirAdi {
            return "\(district), \(city)"
        }
        return "Konum seçiniz"
    }

    var todayPrayerRows: [PrayerTime] {
        guard let today = prayerDays.first(where: { isToday($0) }) ?? prayerDays.first else { return [] }

        let rows: [PrayerTime] = [
            PrayerTime(name: "İmsak", time: today.imsak, icon: "sunrise"),
            PrayerTime(name: "Güneş", time: today.gunes, icon: "sun.max"),
            PrayerTime(name: "Öğle", time: today.ogle, icon: "sun.max.fill"),
            PrayerTime(name: "İkindi", time: today.ikindi, icon: "sun.haze"),
            PrayerTime(name: "Akşam", time: today.aksam, icon: "sunset"),
            PrayerTime(name: "Yatsı", time: today.yatsi, icon: "moon.stars")
        ]

        guard let activeName = nextPrayerInfo?.name else { return rows }
        return rows.map { prayer in
            var updated = prayer
            updated.isActive = prayer.name == activeName
            return updated
        }
    }

    var nextPrayerInfo: (name: String, time: String, remaining: String)? {
        _ = now
        guard let today = prayerDays.first(where: { isToday($0) }) ?? prayerDays.first else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        formatter.locale = Locale(identifier: "tr_TR")

        let namesAndTimes: [(String, String)] = [
            ("İmsak", today.imsak),
            ("Öğle", today.ogle),
            ("İkindi", today.ikindi),
            ("Akşam", today.aksam),
            ("Yatsı", today.yatsi)
        ]

        for (name, time) in namesAndTimes {
            guard let date = formatter.date(from: "\(today.miladiTarihKisa) \(time)") else { continue }
            if date > Date() {
                return (name, time, remainingString(until: date))
            }
        }

        return nil
    }

    private func filterThreeDays(from days: [PrayerDay]) -> [PrayerDay] {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "tr_TR")

        let today = Calendar.current.startOfDay(for: Date())
        let limit = Calendar.current.date(byAdding: .day, value: 2, to: today) ?? today

        return days.filter { day in
            guard let date = formatter.date(from: day.miladiTarihKisa) else { return false }
            let normalized = Calendar.current.startOfDay(for: date)
            return normalized >= today && normalized <= limit
        }
    }

    private func isToday(_ day: PrayerDay) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        guard let date = formatter.date(from: day.miladiTarihKisa) else { return false }
        return Calendar.current.isDateInToday(date)
    }

    private func remainingString(until date: Date) -> String {
        let diff = max(0, Int(date.timeIntervalSinceNow))
        let h = diff / 3600
        let m = (diff % 3600) / 60
        let s = diff % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    private func startClock() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.now = Date()
        }
    }
}
