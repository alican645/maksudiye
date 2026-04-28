//
//  QuranView.swift
//  Maksudiye
//

import SwiftUI

struct QuranView: View {
    @State private var currentPage: Int = 293
    private let totalPages: Int = 604

    var body: some View {
        ScrollView {
            VStack(spacing: 48) {
                SurahSelectorPill(suraNumber: 18, suraName: "Al-Kahf")
                    .padding(.bottom, 16)

                BismillahDivider()

                VerseContentCard(verses: QuranSamples.alKahfOpening)

                QuranPaginationBar(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPrevious: { if currentPage > 1 { currentPage -= 1 } },
                    onNext: { if currentPage < totalPages { currentPage += 1 } }
                )
            }
            .padding(.horizontal, AppMetrics.pageHorizontalPadding)
            .padding(.vertical, 32)
            .padding(.bottom, 32)
        }
        .background(AppColors.background)
    }
}

#Preview {
    QuranView()
}
