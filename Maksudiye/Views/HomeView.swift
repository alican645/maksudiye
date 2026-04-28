//
//  HomeView.swift
//  Maksudiye
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = PrayerTimesViewModel()
    @Environment(\.scenePhase) private var scenePhase

    private let quickActions: [QuickAction] = [
        QuickAction(title: "Bağış Yap", icon: "heart"),
        QuickAction(title: "Etkinlikler", icon: "calendar"),
        QuickAction(title: "Duyurular", icon: "megaphone"),
        QuickAction(title: "İletişim", icon: "questionmark.circle")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppMetrics.sectionSpacing) {
                NextPrayerCard(
                    prayerName: viewModel.nextPrayerInfo?.name ?? "-",
                    time: viewModel.nextPrayerInfo?.time ?? "--:--",
                    remaining: viewModel.nextPrayerInfo?.remaining ?? "--:--:--",
                    onAction: { viewModel.showLocationPicker = true }
                )

                PrayerTimesList(location: viewModel.locationTitle, prayers: viewModel.todayPrayerRows)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VerseOfTheDayCard(
                    arabicText: "يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
                    translation: "\"Ey iman edenler! Sabır ve namazla yardım dileyin. Şüphesiz Allah sabredenlerin yanındadır.\"",
                    reference: "Bakara, 153"
                )

                CharitableActionCard(
                    title: "Vakıf Çalışmaları",
                    subtitle: "Eğitim ve yardım projelerimize destek olun."
                )
                .frame(height: 180)

                QuickActionGrid(actions: quickActions)
            }
            .padding(.horizontal, AppMetrics.pageHorizontalPadding)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .background(AppColors.background)
        .task {
            await viewModel.bootstrap()
        }
        .sheet(isPresented: $viewModel.showLocationPicker) {
            LocationSelectionSheet(viewModel: viewModel)
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task { await viewModel.refreshIfNeeded() }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Yükleniyor...")
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

private struct LocationSelectionSheet: View {
    @ObservedObject var viewModel: PrayerTimesViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("İl") {
                    Picker("Şehir", selection: Binding(
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
                }

                Section("İlçe") {
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
            }
            .navigationTitle("Konum Seçimi")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        Task { await viewModel.saveSelectionAndLoad() }
                    }
                    .disabled(viewModel.selectedCity == nil || viewModel.selectedDistrict == nil)
                }
            }
        }
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

#Preview {
    HomeView()
}
