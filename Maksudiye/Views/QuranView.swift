//
//  QuranView.swift
//  Maksudiye
//

import SwiftUI

struct QuranView: View {
    @AppStorage("quran.currentPage") private var persistedPage: Int = 1
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
    @State private var isLoadingJuz: Bool = false
    @State private var activeTab: QuranTab = .page
    @State private var isFullScreenReading: Bool = false
    @State private var pageReaderScrollTarget = UUID()
    @State private var fullScreenScrollTarget = UUID()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Picker("Okuma Türü", selection: $activeTab) {
                    ForEach(QuranTab.allCases, id: \.self) { tab in
                        Text(tab.title).tag(tab)
                    }
                }
                .pickerStyle(.segmented)

                if activeTab == .page {
                    Button {
                        isFullScreenReading = true
                    } label: {
                        Label("Tam Ekran Oku", systemImage: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.primaryDark)
                }

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
            currentPage = max(1, min(persistedPage, totalPages))
            if surahs.isEmpty { await loadSurahList() }
            if pageVerses.isEmpty { await loadPage(number: currentPage) }
        }
        .task(id: currentPage) {
            persistedPage = currentPage
            pageReaderScrollTarget = UUID()
            fullScreenScrollTarget = UUID()
            await loadPage(number: currentPage)
        }
        .fullScreenCover(isPresented: $isFullScreenReading) {
            FullScreenQuranReader(
                verses: pageVerses,
                currentPage: currentPage,
                totalPages: totalPages,
                onClose: { isFullScreenReading = false },
                onPrevious: { if currentPage > 1 { currentPage -= 1 } },
                onNext: { if currentPage < totalPages { currentPage += 1 } },
                scrollTarget: fullScreenScrollTarget
            )
        }
    }

    private var pageReader: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 16) {
                Color.clear
                    .frame(height: 0)
                    .id(pageReaderScrollTarget)

                SurahSelectorPill(
                    suraNumber: inferredSurahNumber,
                    suraName: inferredSurahName
                )

                BismillahDivider()

                juzJumpControl

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
            .onChange(of: pageReaderScrollTarget) { _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(pageReaderScrollTarget, anchor: .top)
                }
            }
        }
    }

    private var juzJumpControl: some View {
        Menu {
            ForEach(1...30, id: \.self) { juz in
                Button("Cüz \(juz)") {
                    Task { await jumpToJuz(juz) }
                }
            }
        } label: {
            HStack {
                Text("Cüz: \(inferredJuzNumber)")
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                if isLoadingJuz {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(AppColors.textSecondary)
                }
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

    private var surahReader: some View {
        VStack(spacing: 16) {
            if isLoadingSurahList {
                ProgressView("Sureler yükleniyor...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if !surahs.isEmpty {
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 0) {
                        ForEach(surahs) { surah in
                            Button {
                                Task { await loadSurah(number: surah.number) }
                            } label: {
                                HStack(spacing: 12) {
                                    Text("\(surah.number).")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(AppColors.textSecondary)
                                        .frame(width: 28, alignment: .leading)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(surah.englishName)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(AppColors.textPrimary)

                                        Text(surah.name)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(AppColors.textSecondary)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("\(surah.numberOfAyahs) Ayet")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(AppColors.textSecondary)

                                        Text(surah.revelationType)
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundStyle(AppColors.textSecondary.opacity(0.85))
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedSurah?.number == surah.number ? AppColors.surface : Color.clear)
                                )
                            }
                            .buttonStyle(.plain)

                            Divider()
                                .padding(.leading, 14)
                                .padding(.vertical, 2)
                        }
                    }
                }
                .frame(maxHeight: 360)
                .background(
                    RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                        .fill(AppColors.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                        .stroke(AppColors.borderSoft, lineWidth: 1)
                )
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

    private var inferredJuzNumber: Int {
        pageVerses.first?.juz ?? 1
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
    private func jumpToJuz(_ juz: Int) async {
        isLoadingJuz = true
        pageError = nil
        do {
            let response: QuranJuzResponse = try await QuranAPI.shared.fetch(path: "juz/\(juz)/quran-uthmani")
            if let firstPage = response.data.ayahs.first?.page {
                currentPage = firstPage
            } else {
                pageError = "Cüz başlangıç sayfası bulunamadı."
            }
        } catch {
            pageError = "Cüz bilgisi getirilemedi."
        }
        isLoadingJuz = false
    }

    @MainActor
    private func loadSurahList() async {
        isLoadingSurahList = true
        do {
            let response: SurahListResponse = try await QuranAPI.shared.fetch(path: "surah")
            surahs = response.data
            if selectedSurah == nil, let firstSurah = surahs.first {
                await loadSurah(number: firstSurah.number)
            }
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

private struct QuranJuzResponse: Decodable {
    let data: QuranPageData
}

private struct SurahListResponse: Decodable {
    let data: [SurahSummary]
}

private struct SurahSummary: Decodable, Identifiable {
    let number: Int
    let name: String
    let englishName: String
    let numberOfAyahs: Int
    let revelationType: String

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
    let surah: SurahMeta?
    let juz: Int?
    let page: Int?

    var asVerse: QuranVerse {
        QuranVerse(
            number: numberInSurah,
            tokens: tokenizeArabicText(),
            juz: juz,
            surahNumber: surah?.number,
            surahName: surah?.name
        )
    }

    private func tokenizeArabicText() -> [QuranToken] {
        text
            .split(separator: " ", omittingEmptySubsequences: false)
            .map { word in
                let tokenText = "\(word) "
                return QuranToken(text: tokenText, style: isAllahWord(String(word)) ? .allah : .normal)
            }
    }

    private func isAllahWord(_ rawWord: String) -> Bool {
        let punctuation = CharacterSet(charactersIn: "ۚۖۗۙۛۜ۝۞،؛,.!?()[]{}\"'«»")
        let stripped = rawWord.trimmingCharacters(in: punctuation)
        let normalized = stripped
            .replacingOccurrences(of: "ﷲ", with: "الله")
            .folding(options: .diacriticInsensitive, locale: .current)
        return normalized.contains("الله")
            || normalized.contains("اللَّه")
            || normalized.contains("ٱللَّه")
    }
}

private struct SurahMeta: Decodable {
    let number: Int
    let name: String
    let englishName: String
}

#Preview {
    QuranView()
}

private struct FullScreenQuranReader: View {
    let verses: [QuranVerse]
    let currentPage: Int
    let totalPages: Int
    let onClose: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    let scrollTarget: UUID
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Color(red: 232 / 255, green: 219 / 255, blue: 176 / 255)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.black.opacity(0.75))
                    }

                    Spacer()

                    Text("Sayfa \(currentPage)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black.opacity(0.8))
                }

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        Color.clear
                            .frame(height: 0)
                            .id("fullScreenTop")

                        VerseContentCard(
                            verses: verses,
                            showsActions: false,
                            mushafMode: true
                        )
                        .padding(.bottom, 8)
                    }
                    .onChange(of: scrollTarget) { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("fullScreenTop", anchor: .top)
                        }
                    }
                    .onChange(of: currentPage) { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("fullScreenTop", anchor: .top)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .scrollIndicators(.visible)

                HStack(spacing: 12) {
                    Button("Önceki") { onPrevious() }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.primaryDark)
                        .disabled(currentPage <= 1)

                    Button("Sonraki") { onNext() }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.primaryDark)
                        .disabled(currentPage >= totalPages)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .offset(x: dragOffset)
            .animation(.easeOut(duration: 0.2), value: dragOffset)
            .simultaneousGesture(
                DragGesture(minimumDistance: 40, coordinateSpace: .local)
                    .onChanged { value in
                        guard isIntentionalPageSwipe(value) else {
                            dragOffset = 0
                            return
                        }
                        dragOffset = value.translation.width * 0.15
                    }
                    .onEnded { value in
                        defer { dragOffset = 0 }
                        guard isIntentionalPageSwipe(value) else { return }

                        if value.translation.width >= 150 {
                            onPrevious()
                        } else if value.translation.width <= -150 {
                            onNext()
                        }
                    }
            )
        }
    }

    private func isIntentionalPageSwipe(_ value: DragGesture.Value) -> Bool {
        let horizontal = abs(value.translation.width)
        let vertical = abs(value.translation.height)
        return horizontal > max(90, vertical * 1.6)
    }
}
