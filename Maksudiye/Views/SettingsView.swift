import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: PrayerTimesViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Konum") {
                    Picker("İl", selection: Binding(
                        get: { viewModel.selectedCity?.id },
                        set: { newID in
                            guard let id = newID,
                                  let city = viewModel.cities.first(where: { $0.id == id }) else { return }
                            Task { await viewModel.fetchDistrictsIfNeeded(for: city) }
                        }
                    )) {
                        Text("Seçiniz").tag(String?.none)
                        ForEach(viewModel.cities) { city in
                            Text(city.sehirAdi).tag(Optional(city.id))
                        }
                    }

                    Picker("İlçe", selection: Binding(
                        get: { viewModel.selectedDistrict?.id },
                        set: { newID in
                            guard let id = newID else { return }
                            viewModel.selectedDistrict = viewModel.districts.first(where: { $0.id == id })
                        }
                    )) {
                        Text("Seçiniz").tag(String?.none)
                        ForEach(viewModel.districts) { district in
                            Text(district.ilceAdi).tag(Optional(district.id))
                        }
                    }
                }

                Section {
                    Button("Kaydet ve Bildirimleri Güncelle") {
                        Task {
                            await viewModel.saveSelectionAndLoad()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.selectedCity == nil || viewModel.selectedDistrict == nil)
                }
            }
            .navigationTitle("Ayarlar")
            .task {
                if viewModel.cities.isEmpty {
                    await viewModel.loadCities()
                }

                if let selectedCity = viewModel.selectedCity {
                    await viewModel.fetchDistrictsIfNeeded(for: selectedCity)
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: PrayerTimesViewModel())
}
