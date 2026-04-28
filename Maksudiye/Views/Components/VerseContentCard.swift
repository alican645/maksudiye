//
//  VerseContentCard.swift
//  Maksudiye
//

import SwiftUI
import UIKit

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
    var surahNumber: Int? = nil
    var surahName: String? = nil
}

struct VerseContentCard: View {
    let verses: [QuranVerse]
    var mushafMode: Bool = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            VStack(alignment: .trailing, spacing: 20) {
                ForEach(Array(groupedVerses.enumerated()), id: \.element.id) { index, group in
                    if index > 0,
                       let surahName = group.surahName,
                       let surahNumber = group.surahNumber {
                        SurahTransitionBand(surahNumber: surahNumber, surahName: surahName)
                    }

                    JustifiedArabicTextView(
                        attributedText: attributedFlow(for: group.verses)
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
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

    private var groupedVerses: [SurahVerseGroup] {
        guard let firstVerse = verses.first else { return [] }
        var groups: [SurahVerseGroup] = [
            SurahVerseGroup(
                surahNumber: firstVerse.surahNumber,
                surahName: firstVerse.surahName,
                verses: [firstVerse]
            )
        ]

        for verse in verses.dropFirst() {
            if groups.last?.surahNumber == verse.surahNumber {
                groups[groups.count - 1].verses.append(verse)
            } else {
                groups.append(
                    SurahVerseGroup(
                        surahNumber: verse.surahNumber,
                        surahName: verse.surahName,
                        verses: [verse]
                    )
                )
            }
        }

        return groups
    }

    private func attributedFlow(for verses: [QuranVerse]) -> NSAttributedString {
        let allahColor = UIColor(red: 185 / 255, green: 28 / 255, blue: 28 / 255, alpha: 1)
        let baseColor = AppColors.textPrimary
        let markerColor = AppColors.primaryDark
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        paragraphStyle.baseWritingDirection = .rightToLeft
        paragraphStyle.lineSpacing = 18

        let stream = NSMutableAttributedString()
        for verse in verses {
            for token in verse.tokens {
                let font = UIFont(name: "GeezaPro", size: 32) ?? UIFont.systemFont(ofSize: 32)
                switch token.style {
                case .normal:
                    stream.append(
                        NSAttributedString(
                            string: token.text,
                            attributes: [
                                .font: font,
                                .foregroundColor: UIColor(baseColor),
                                .paragraphStyle: paragraphStyle
                            ]
                        )
                    )
                case .allah:
                    stream.append(
                        NSAttributedString(
                            string: token.text,
                            attributes: [
                                .font: font,
                                .foregroundColor: allahColor,
                                .paragraphStyle: paragraphStyle
                            ]
                        )
                    )
                }
            }
            stream.append(
                NSAttributedString(
                    string: " \(arabicMarker(for: verse.number)) ",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                        .foregroundColor: UIColor(markerColor),
                        .paragraphStyle: paragraphStyle
                    ]
                )
            )
        }

        return stream
    }

    private func arabicMarker(for number: Int) -> String {
        let digits = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
        let arabicNumber = String(number).compactMap { digits[Int(String($0)) ?? 0] }.joined()
        return "﴿\(arabicNumber)﴾"
    }
}

private struct SurahVerseGroup: Identifiable {
    let id = UUID()
    let surahNumber: Int?
    let surahName: String?
    var verses: [QuranVerse]
}

private struct SurahTransitionBand: View {
    let surahNumber: Int
    let surahName: String

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Text("سُورَة")
                    .font(.custom("GeezaPro", size: 20))
                    .foregroundStyle(Color.white.opacity(0.95))
                Text("\(surahName) (\(surahNumber))")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.white)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 132 / 255, green: 116 / 255, blue: 29 / 255))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 214 / 255, green: 194 / 255, blue: 88 / 255), lineWidth: 2)
                )
        )
    }
}

private struct JustifiedArabicTextView: UIViewRepresentable {
    let attributedText: NSAttributedString

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textAlignment = .justified
        textView.semanticContentAttribute = .forceRightToLeft
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let width = proposal.width ?? UIScreen.main.bounds.width - 48
        let fitting = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: fitting.height)
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
