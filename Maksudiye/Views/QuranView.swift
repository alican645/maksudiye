//
//  QuranView.swift
//  Maksudiye
//

import SwiftUI

struct QuranView: View {
    @AppStorage("quran.currentPage") private var persistedPage: Int = 1
    @AppStorage("quran.offlineDownloadCompleted") private var isOfflineDownloadCompleted: Bool = false
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
    @State private var isSurahFullScreenReading: Bool = false
    @State private var pageReaderScrollTarget = UUID()
    @State private var fullScreenScrollTarget = UUID()
    @State private var showOfflineDownloadPrompt: Bool = false
    @State private var hasPromptedForDownload: Bool = false
    @State private var isDownloadingOfflineData: Bool = false
    @State private var downloadProgress: Double = 0
    @State private var downloadMessage: String = ""
    @State private var offlineBundleLoaded: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !isOfflineDownloadCompleted {
                    offlineDownloadCard
                }

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
            await loadOfflineBundle()
            if !isOfflineDownloadCompleted, !hasPromptedForDownload {
                showOfflineDownloadPrompt = true
                hasPromptedForDownload = true
            }
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
                title: "Sayfa \(currentPage)",
                onClose: { isFullScreenReading = false },
                onPrevious: { if currentPage > 1 { currentPage -= 1 } },
                onNext: { if currentPage < totalPages { currentPage += 1 } },
                scrollTarget: fullScreenScrollTarget
            )
        }
        .fullScreenCover(isPresented: $isSurahFullScreenReading) {
            if let selectedSurah {
                FullScreenQuranReader(
                    verses: selectedSurah.ayahs.map { $0.asVerse },
                    title: "Sure \(selectedSurah.number) • \(selectedSurah.englishName)",
                    onClose: { isSurahFullScreenReading = false },
                    onPrevious: {},
                    onNext: {},
                    scrollTarget: fullScreenScrollTarget,
                    showsNavigationButtons: false
                )
            }
        }
        .alert("Kur'an-ı Kerim indirilsin mi?", isPresented: $showOfflineDownloadPrompt) {
            Button("Haydi Başla") {
                Task { await startOfflineDownload() }
            }
            Button("Sonra", role: .cancel) {}
        } message: {
            Text("Kullanıcıya kesintisiz okuma için tüm sayfaları ve sureleri indirmeniz gerekiyor.")
        }
        .tint(.green)
    }

    private var offlineDownloadCard: some View {
        VStack(spacing: 12) {
            Text("Kur'an-ı Kerim'i indirmeniz gerekiyor")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            if isDownloadingOfflineData {
                ProgressView(value: downloadProgress, total: 1.0)
                    .tint(.green)
                Text(downloadMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                Button {
                    showOfflineDownloadPrompt = true
                } label: {
                    Label("Haydi Başla", systemImage: "arrow.down.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                .fill(AppColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                .stroke(AppColors.borderSoft, lineWidth: 1)
        )
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
                                Task {
                                    await loadSurah(number: surah.number)
                                    if selectedSurah != nil {
                                        fullScreenScrollTarget = UUID()
                                        isSurahFullScreenReading = true
                                    }
                                }
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
                ProgressView("Sure hazırlanıyor...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else if let surahError {
                errorState(message: surahError) {
                    if let selectedSurah {
                        Task { await loadSurah(number: selectedSurah.number) }
                    }
                }
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
        if let cachedPage = QuranOfflineStore.shared.page(number: number) {
            totalPages = 604
            pageVerses = cachedPage.ayahs.map { $0.asVerse }
            currentPageSurah = cachedPage.ayahs.first?.surah
            pageError = nil
            return
        }
        pageError = "Bu sayfa çevrimdışı veride yok. Önce indirme işlemini tamamlayın."
    }

    @MainActor
    private func jumpToJuz(_ juz: Int) async {
        if let cachedStartPage = QuranOfflineStore.shared.juzStartPage(for: juz) {
            currentPage = cachedStartPage
            return
        }
        pageError = "Cüz bilgisi çevrimdışı veride yok. Önce indirme işlemini tamamlayın."
    }

    @MainActor
    private func loadSurahList() async {
        if !offlineBundleLoaded {
            await loadOfflineBundle()
        }

        surahs = QuranOfflineStore.shared.surahList()
        surahError = surahs.isEmpty ? "Sure listesi çevrimdışı veride yok. Önce indirme işlemini tamamlayın." : nil
    }

    @MainActor
    private func loadSurah(number: Int) async {
        if let cachedSurah = QuranOfflineStore.shared.surah(number: number) {
            selectedSurah = cachedSurah
            surahError = nil
            return
        }
        surahError = "Seçilen sure çevrimdışı veride yok. Önce indirme işlemini tamamlayın."
    }

    @MainActor
    private func loadOfflineBundle() async {
        guard !offlineBundleLoaded else { return }
        offlineBundleLoaded = true
        do {
            try QuranOfflineStore.shared.loadFromDisk()
        } catch {
            // Geçersiz cache varsa sessizce devam edilir.
        }
    }

    @MainActor
    private func startOfflineDownload() async {
        guard !isDownloadingOfflineData else { return }
        isDownloadingOfflineData = true
        downloadProgress = 0
        downloadMessage = "İndirme başlatılıyor..."
        pageError = nil
        surahError = nil

        let totalStepCount = 604 + 114 + 1
        var completedSteps = 0
        var freshlyDownloadedPages: [Int: QuranPageData] = [:]
        var freshlyDownloadedSurahs: [Int: SurahDetail] = [:]
        var fetchedSurahList: [SurahSummary] = []
        var juzStartPages: [Int: Int] = [:]

        do {
            for page in 1...604 {
                let response: QuranPageResponse = try await QuranAPI.shared.fetch(path: "page/\(page)/quran-uthmani")
                freshlyDownloadedPages[page] = response.data

                for ayah in response.data.ayahs {
                    if let juz = ayah.juz, let ayahPage = ayah.page, juzStartPages[juz] == nil {
                        juzStartPages[juz] = ayahPage
                    }
                }

                completedSteps += 1
                downloadProgress = Double(completedSteps) / Double(totalStepCount)
                downloadMessage = "Sayfalar indiriliyor: \(page)/604"
            }

            let surahListResponse: SurahListResponse = try await QuranAPI.shared.fetch(path: "surah")
            fetchedSurahList = surahListResponse.data
            completedSteps += 1
            downloadProgress = Double(completedSteps) / Double(totalStepCount)
            downloadMessage = "Sure listesi indirildi"

            for surah in 1...114 {
                let response: SurahDetailResponse = try await QuranAPI.shared.fetch(path: "surah/\(surah)/quran-uthmani")
                freshlyDownloadedSurahs[surah] = response.data
                completedSteps += 1
                downloadProgress = Double(completedSteps) / Double(totalStepCount)
                downloadMessage = "Sureler indiriliyor: \(surah)/114"
            }

            QuranOfflineStore.shared.replaceAll(
                pages: freshlyDownloadedPages,
                surahList: fetchedSurahList,
                surahs: freshlyDownloadedSurahs,
                juzStartPages: juzStartPages
            )
            try QuranOfflineStore.shared.saveToDisk()
            isOfflineDownloadCompleted = true
            downloadMessage = "İndirme tamamlandı. Artık çevrimdışı okuyabilirsiniz."
            if surahs.isEmpty {
                surahs = fetchedSurahList
            }
            if pageVerses.isEmpty, let firstPage = freshlyDownloadedPages[currentPage] {
                pageVerses = firstPage.ayahs.map { $0.asVerse }
            }
        } catch {
            pageError = "İndirme sırasında bir hata oluştu. Lütfen tekrar deneyin."
        }

        isDownloadingOfflineData = false
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

private struct QuranPageData: Codable {
    let ayahs: [Ayah]
}

private struct QuranJuzResponse: Decodable {
    let data: QuranPageData
}

private struct SurahListResponse: Decodable {
    let data: [SurahSummary]
}

private struct SurahSummary: Codable, Identifiable {
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

private struct SurahDetail: Codable {
    let number: Int
    let name: String
    let englishName: String
    let ayahs: [Ayah]
}

private struct Ayah: Codable {
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

private struct SurahMeta: Codable {
    let number: Int
    let name: String
    let englishName: String
}

private final class QuranOfflineStore {
    static let shared = QuranOfflineStore()

    private var pages: [Int: QuranPageData] = [:]
    private var surahListValue: [SurahSummary] = []
    private var surahs: [Int: SurahDetail] = [:]
    private var juzStartPages: [Int: Int] = [:]

    private init() {}

    func page(number: Int) -> QuranPageData? {
        pages[number]
    }

    func setPage(_ page: QuranPageData, number: Int) {
        pages[number] = page
    }

    func surahList() -> [SurahSummary] {
        surahListValue
    }

    func setSurahList(_ list: [SurahSummary]) {
        surahListValue = list
    }

    func surah(number: Int) -> SurahDetail? {
        surahs[number]
    }

    func setSurah(_ surah: SurahDetail, number: Int) {
        surahs[number] = surah
    }

    func juzStartPage(for juz: Int) -> Int? {
        juzStartPages[juz]
    }

    func setJuzStartPage(_ page: Int, for juz: Int) {
        juzStartPages[juz] = page
    }

    func replaceAll(
        pages: [Int: QuranPageData],
        surahList: [SurahSummary],
        surahs: [Int: SurahDetail],
        juzStartPages: [Int: Int]
    ) {
        self.pages = pages
        self.surahListValue = surahList
        self.surahs = surahs
        self.juzStartPages = juzStartPages
    }

    func saveToDisk() throws {
        let bundle = OfflineQuranBundle(
            pages: pages,
            surahList: surahListValue,
            surahs: surahs,
            juzStartPages: juzStartPages
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(bundle)
        let folder = try storageDirectory()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try data.write(to: folder.appending(path: "offline-quran.json"), options: .atomic)
    }

    func loadFromDisk() throws {
        let url = try storageDirectory().appending(path: "offline-quran.json")
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let bundle = try decoder.decode(OfflineQuranBundle.self, from: data)
        pages = bundle.pages
        surahListValue = bundle.surahList
        surahs = bundle.surahs
        juzStartPages = bundle.juzStartPages
    }

    private func storageDirectory() throws -> URL {
        try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appending(path: "QuranOfflineCache")
    }
}

private struct OfflineQuranBundle: Codable {
    let pages: [Int: QuranPageData]
    let surahList: [SurahSummary]
    let surahs: [Int: SurahDetail]
    let juzStartPages: [Int: Int]
}

#Preview {
    QuranView()
}

private struct FullScreenQuranReader: View {
    let verses: [QuranVerse]
    let title: String
    let onClose: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    let scrollTarget: UUID
    var showsNavigationButtons: Bool = true
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

                    Text(title)
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
                            mushafMode: true
                        )
                        .padding(.bottom, 8)
                    }
                    .onChange(of: scrollTarget) { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("fullScreenTop", anchor: .top)
                        }
                    }
                    .onChange(of: title) { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("fullScreenTop", anchor: .top)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .scrollIndicators(.visible)

                if showsNavigationButtons {
                    HStack(spacing: 12) {
                        Button("Önceki") { onPrevious() }
                            .buttonStyle(.borderedProminent)
                            .tint(AppColors.primaryDark)

                        Button("Sonraki") { onNext() }
                            .buttonStyle(.borderedProminent)
                            .tint(AppColors.primaryDark)
                    }
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

                        if !showsNavigationButtons {
                            return
                        } else if value.translation.width >= 150 {
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
