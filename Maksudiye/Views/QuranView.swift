//
//  QuranView.swift
//  Maksudiye
//

import SwiftUI

struct QuranView: View {
    @State private var currentPage: Int = 1
    @State private var totalPages: Int = 604
    @State private var pageVerses: [QuranVerse] = []
    @State private var surahs: [SurahSummary] = []
    @State private var selectedSurah: SurahDetail?
    @State private var currentPageSurah: SurahMeta?
    @State private var isLoadingPage: Bool = false
    @State private var isLoadingSurah: Bool = false
    @State private var isLoadingSurahList: Bool = false
    @State private var pageError: String?
    @State private var surahError: String?
    @State private var activeTab: QuranTab = .page

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Picker("Okuma Türü", selection: $activeTab) {
                    ForEach(QuranTab.allCases, id: \.self) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)

                switch activeTab {
                case .page:
                    pageReader
                case .surah:
                    surahReader
                }
            }
            .padding(.horizontal, AppMetrics.pageHorizontalPadding)
            .padding(.vertical, 24)
            .padding(.bottom, 32)
        }
        .background(AppColors.background)
        .task {
            if surahs.isEmpty { await loadSurahList() }
            if pageVerses.isEmpty { await loadPage(number: currentPage) }
        }
        .task(id: currentPage) {
            await loadPage(number: currentPage)
        }
    }

    private var pageReader: some View {
        VStack(spacing: 16) {
            SurahSelectorPill(
                suraNumber: inferredSurahNumber,
                suraName: inferredSurahName
            )

            BismillahDivider()

            if isLoadingPage {
                ProgressView("Sayfa yükleniyor...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if let pageError {
                errorState(message: pageError) {
                    Task { await loadPage(number: currentPage) }
                }
            } else {
                VerseContentCard(verses: pageVerses)
            }

            QuranPaginationBar(
                currentPage: currentPage,
                totalPages: totalPages,
                onPrevious: { if currentPage > 1 { currentPage -= 1 } },
                onNext: { if currentPage < totalPages { currentPage += 1 } }
            )
        }
    }

    private var surahReader: some View {
        VStack(spacing: 16) {
            if isLoadingSurahList {
                ProgressView("Sureler yükleniyor...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if !surahs.isEmpty {
                Menu {
                    ForEach(surahs) { surah in
                        Button("\(surah.number). \(surah.englishName) - \(surah.name)") {
                            Task { await loadSurah(number: surah.number) }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedSurah.map { "\($0.number). \($0.englishName)" } ?? "Sure Seç")
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                            .fill(AppColors.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                            .stroke(AppColors.borderSoft, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            if isLoadingSurah {
                ProgressView("Sure yükleniyor...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if let surahError {
                errorState(message: surahError) {
                    if let selectedSurah {
                        Task { await loadSurah(number: selectedSurah.number) }
                    }
                }
            } else if let selectedSurah {
                SurahSelectorPill(suraNumber: selectedSurah.number, suraName: selectedSurah.englishName)
                VerseContentCard(verses: selectedSurah.ayahs.map { $0.asVerse })
            } else {
                Text("Okumak için bir sure seçin")
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
    }

    private func errorState(message: String, retry: @escaping () -> Void) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
            Button("Tekrar Dene", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                .fill(AppColors.surface)
        )
    }

    private var inferredSurahNumber: Int {
        currentPageSurah?.number ?? 1
    }

    private var inferredSurahName: String {
        currentPageSurah?.englishName ?? "Sayfa \(currentPage)"
    }

    @MainActor
    private func loadPage(number: Int) async {
        isLoadingPage = true
        pageError = nil
        do {
            let response: QuranPageResponse = try await QuranAPI.shared.fetch(path: "page/\(number)/quran-uthmani")
            totalPages = 604
            pageVerses = response.data.ayahs.map { $0.asVerse }
            currentPageSurah = response.data.ayahs.first?.surah
        } catch {
            pageError = "Sayfa getirilemedi. Lütfen bağlantınızı kontrol edin."
        }
        isLoadingPage = false
    }

    @MainActor
    private func loadSurahList() async {
        isLoadingSurahList = true
        do {
            let response: SurahListResponse = try await QuranAPI.shared.fetch(path: "surah")
            surahs = response.data
        } catch {
            surahError = "Sure listesi alınamadı."
        }
        isLoadingSurahList = false
    }

    @MainActor
    private func loadSurah(number: Int) async {
        isLoadingSurah = true
        surahError = nil
        do {
            let response: SurahDetailResponse = try await QuranAPI.shared.fetch(path: "surah/\(number)/quran-uthmani")
            selectedSurah = response.data
        } catch {
            surahError = "Seçilen sure getirilemedi."
        }
        isLoadingSurah = false
    }
}

private enum QuranTab: CaseIterable {
    case page
    case surah

    var title: String {
        switch self {
        case .page: return "Sayfa"
        case .surah: return "Sure"
        }
    }
}

private struct QuranAPI {
    static let shared = QuranAPI()
    private let baseURL = URL(string: "https://api.alquran.cloud/v1/")!

    func fetch<T: Decodable>(path: String) async throws -> T {
        let url = baseURL.appending(path: path)
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

private struct QuranPageResponse: Decodable {
    let data: QuranPageData
}

private struct QuranPageData: Decodable {
    let ayahs: [Ayah]
}

private struct SurahListResponse: Decodable {
    let data: [SurahSummary]
}

private struct SurahSummary: Decodable, Identifiable {
    let number: Int
    let name: String
    let englishName: String

    var id: Int { number }
}

private struct SurahDetailResponse: Decodable {
    let data: SurahDetail
}

private struct SurahDetail: Decodable {
    let number: Int
    let name: String
    let englishName: String
    let ayahs: [Ayah]
}

private struct Ayah: Decodable {
    let numberInSurah: Int
    let text: String
    let surah: SurahMeta

    var asVerse: QuranVerse {
        QuranVerse(number: numberInSurah, tokens: [QuranToken(text: "\(text) ")])
    }
}

private struct SurahMeta: Decodable {
    let number: Int
    let englishName: String
}

#Preview {
    QuranView()
}
