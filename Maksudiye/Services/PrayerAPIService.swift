import Foundation

struct PrayerAPIService {
    private let baseURL = URL(string: "https://ezanvakti.emushaf.net")!

    func fetchCities(countryID: Int = 2) async throws -> [PrayerCity] {
        let url = baseURL.appending(path: "sehirler/\(countryID)")
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)
        return try JSONDecoder().decode([PrayerCity].self, from: data)
    }

    func fetchDistricts(cityID: String) async throws -> [PrayerDistrict] {
        let url = baseURL.appending(path: "ilceler/\(cityID)")
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)
        return try JSONDecoder().decode([PrayerDistrict].self, from: data)
    }

    func fetchPrayerTimes(districtID: String) async throws -> [PrayerDay] {
        let url = baseURL.appending(path: "vakitler/\(districtID)")
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)
        return try JSONDecoder().decode([PrayerDay].self, from: data)
    }

    private func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
