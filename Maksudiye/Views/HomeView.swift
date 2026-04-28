//
//  HomeView.swift
//  Maksudiye
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: PrayerTimesViewModel
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
        .onChange(of: scenePhase) { newPhase in
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
    @State private var citySearchText = ""
    @State private var districtSearchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        locationSection(
                            title: "İl Seçin",
                            subtitle: "Bulunduğunuz şehri seçin",
                            selectionText: viewModel.selectedCity?.sehirAdi ?? "Şehir seçilmedi",
                            searchText: $citySearchText,
                            placeholder: "Şehir ara",
                            items: filteredCities.map(\.sehirAdi)
                        ) { cityName in
                            guard let city = filteredCities.first(where: { $0.sehirAdi == cityName }) else { return }
                            Task { await viewModel.fetchDistrictsIfNeeded(for: city) }
                        }

                        locationSection(
                            title: "İlçe Seçin",
                            subtitle: "Namaz vakitleri için ilçe belirleyin",
                            selectionText: viewModel.selectedDistrict?.ilceAdi ?? "İlçe seçilmedi",
                            searchText: $districtSearchText,
                            placeholder: "İlçe ara",
                            items: filteredDistricts.map(\.ilceAdi)
                        ) { districtName in
                            viewModel.selectedDistrict = filteredDistricts.first(where: { $0.ilceAdi == districtName })
                        }
                    }
                    .padding(20)
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

    private var filteredCities: [PrayerCity] {
        if citySearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return viewModel.cities
        }
        return viewModel.cities.filter { $0.sehirAdi.localizedCaseInsensitiveContains(citySearchText) }
    }

    private var filteredDistricts: [PrayerDistrict] {
        if districtSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return viewModel.districts
        }
        return viewModel.districts.filter { $0.ilceAdi.localizedCaseInsensitiveContains(districtSearchText) }
    }

    private func locationSection(
        title: String,
        subtitle: String,
        selectionText: String,
        searchText: Binding<String>,
        placeholder: String,
        items: [String],
        onSelect: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(AppColors.primaryDark)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColors.primary)
                TextField(placeholder, text: searchText)
                    .textInputAutocapitalization(.words)
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColors.borderSoft, lineWidth: 1.2)
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Button {
                            onSelect(item)
                        } label: {
                            Text(item)
                                .font(.system(size: 14, weight: selectionText == item ? .semibold : .regular))
                                .foregroundStyle(selectionText == item ? .white : AppColors.primaryDark)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectionText == item ? AppColors.primary : AppColors.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectionText == item ? AppColors.primary : AppColors.borderSoft, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Label(selectionText, systemImage: "checkmark.seal.fill")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.primaryDark)
        }
        .padding(16)
        .background(AppColors.highlightTint, in: RoundedRectangle(cornerRadius: AppMetrics.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                .stroke(AppColors.borderSoft, lineWidth: 1)
        )
    }
}

#Preview {
    HomeView(viewModel: PrayerTimesViewModel())
}
