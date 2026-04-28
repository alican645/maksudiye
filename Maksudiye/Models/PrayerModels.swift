import Foundation

struct PrayerCity: Codable, Identifiable, Hashable {
    let sehirAdi: String
    let sehirAdiEn: String
    let sehirID: String

    enum CodingKeys: String, CodingKey {
        case sehirAdi = "SehirAdi"
        case sehirAdiEn = "SehirAdiEn"
        case sehirID = "SehirID"
    }

    var id: String { sehirID }
}

struct PrayerDistrict: Codable, Identifiable, Hashable {
    let ilceAdi: String
    let ilceAdiEn: String
    let ilceID: String

    enum CodingKeys: String, CodingKey {
        case ilceAdi = "IlceAdi"
        case ilceAdiEn = "IlceAdiEn"
        case ilceID = "IlceID"
    }

    var id: String { ilceID }
}

struct PrayerDay: Codable, Identifiable, Hashable {
    let hicriTarihUzun: String?
    let miladiTarihKisa: String
    let miladiTarihUzun: String?
    let miladiTarihUzunIso8601: String?
    let aksam: String
    let gunes: String
    let ikindi: String
    let imsak: String
    let ogle: String
    let yatsi: String

    enum CodingKeys: String, CodingKey {
        case hicriTarihUzun = "HicriTarihUzun"
        case miladiTarihKisa = "MiladiTarihKisa"
        case miladiTarihUzun = "MiladiTarihUzun"
        case miladiTarihUzunIso8601 = "MiladiTarihUzunIso8601"
        case aksam = "Aksam"
        case gunes = "Gunes"
        case ikindi = "Ikindi"
        case imsak = "Imsak"
        case ogle = "Ogle"
        case yatsi = "Yatsi"
    }

    var id: String { miladiTarihKisa }
}

struct PrayerSelection: Codable {
    let city: PrayerCity
    let district: PrayerDistrict
}
