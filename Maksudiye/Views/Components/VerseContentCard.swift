//
//  VerseContentCard.swift
//  Maksudiye
//

import SwiftUI

struct QuranToken {
    enum Style {
        case normal
        case allah
    }

    let text: String
    var style: Style = .normal
}

struct QuranVerse: Identifiable {
    let id = UUID()
    let number: Int
    let tokens: [QuranToken]
    var juz: Int? = nil
}

struct VerseContentCard: View {
    let verses: [QuranVerse]
    var showsActions: Bool = true
    var mushafMode: Bool = false
    var onListen: () -> Void = {}
    var onBookmark: () -> Void = {}

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            if showsActions {
                HStack(spacing: 8) {
                    Spacer()

                    Button(action: onListen) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.circle")
                                .font(.system(size: 14, weight: .semibold))
                            Text("DİNLE")
                                .font(.system(size: 12, weight: .semibold))
                                .tracking(0.6)
                        }
                        .foregroundStyle(AppColors.primaryDark)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.clear))
                    }
                    .buttonStyle(.plain)

                    Button(action: onBookmark) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(AppColors.primaryDark)
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                }
            }

            arabicFlow
                .multilineTextAlignment(.center)
                .lineSpacing(20)
                .frame(maxWidth: .infinity)
                .environment(\.layoutDirection, .rightToLeft)
        }
        .padding(mushafMode ? 20 : 24)
        .background(
            RoundedRectangle(cornerRadius: mushafMode ? 6 : 16)
                .fill(mushafMode ? Color(red: 247 / 255, green: 238 / 255, blue: 206 / 255) : AppColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: mushafMode ? 6 : 16)
                .stroke(mushafMode ? Color(red: 130 / 255, green: 108 / 255, blue: 63 / 255) : AppColors.borderSoft, lineWidth: mushafMode ? 2 : 1)
                .padding(mushafMode ? 8 : 0)
        )
        .shadow(color: AppColors.primary.opacity(0.04), radius: 10, y: 4)
    }

    private var arabicFlow: Text {
        let allahColor = Color(red: 185 / 255, green: 28 / 255, blue: 28 / 255)
        let baseColor = AppColors.textPrimary
        let markerColor = AppColors.primaryDark

        var stream = Text("")
        for verse in verses {
            for token in verse.tokens {
                switch token.style {
                case .normal:
                    stream = stream
                        + Text(token.text)
                            .font(.custom("GeezaPro", size: 28))
                            .foregroundColor(baseColor)
                case .allah:
                    stream = stream
                        + Text(token.text)
                            .font(.custom("GeezaPro", size: 28))
                            .foregroundColor(allahColor)
                            .fontWeight(.bold)
                }
            }
            stream = stream
                + Text(" \(arabicMarker(for: verse.number)) ")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(markerColor)
        }
        return stream
    }

    private func arabicMarker(for number: Int) -> String {
        let digits = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
        let arabicNumber = String(number).compactMap { digits[Int(String($0)) ?? 0] }.joined()
        return "﴿\(arabicNumber)﴾"
    }
}

#Preview {
    VerseContentCard(verses: QuranSamples.alKahfOpening)
        .padding()
        .background(AppColors.background)
}

enum QuranSamples {
    static let alKahfOpening: [QuranVerse] = [
        QuranVerse(number: 1, tokens: [
            QuranToken(text: "ٱلْحَمْدُ "),
            QuranToken(text: "لِلَّهِ", style: .allah),
            QuranToken(text: " ٱلَّذِىٓ أَنزَلَ عَلَىٰ عَبْدِهِ ٱلْكِتَـٰبَ وَلَمْ يَجْعَل لَّهُۥ عِوَجَا")
        ]),
        QuranVerse(number: 2, tokens: [
            QuranToken(text: " قَيِّمًۭا لِّيُنذِرَ بَأْسًۭا شَدِيدًۭا مِّن لَّدُنْهُ وَيُبَشِّرَ ٱلْمُؤْمِنِينَ ٱلَّذِينَ يَعْمَلُونَ ٱلصَّـٰلِحَـٰتِ أَنَّ لَهُمْ أَجْرًا حَسَنًۭا")
        ]),
        QuranVerse(number: 3, tokens: [
            QuranToken(text: " مَّـٰكِثِينَ فِيهِ أَبَدًۭا")
        ]),
        QuranVerse(number: 4, tokens: [
            QuranToken(text: " وَيُنذِرَ ٱلَّذِينَ قَالُوا۟ ٱتَّخَذَ "),
            QuranToken(text: "ٱللَّهُ", style: .allah),
            QuranToken(text: " وَلَدًۭا")
        ]),
        QuranVerse(number: 5, tokens: [
            QuranToken(text: " مَّا لَهُم بِهِۦ مِنْ عِلْمٍۢ وَلَا لِـَٔابَآئِهِمْ ۚ كَبُرَتْ كَلِمَةًۭ تَخْرُجُ مِنْ أَفْوَٰهِهِمْ ۚ إِن يَقُولُونَ إِلَّا كَذِبًۭا")
        ])
    ]
}
