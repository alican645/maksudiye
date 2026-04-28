//
//  VerseOfTheDayCard.swift
//  Maksudiye
//

import SwiftUI

struct VerseOfTheDayCard: View {
    let arabicText: String
    let translation: String
    let reference: String
    var onShare: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.accentGold)
                Text("GÜNÜN AYETI")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AppColors.accentGold)
            }

            Text(arabicText)
                .font(.system(size: 18))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)
                .lineSpacing(11)

            Text(translation)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(8)
                .padding(.top, 4)

            HStack {
                Text(reference)
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(0.6)
                    .foregroundStyle(AppColors.textMuted)
                Spacer()
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(AppColors.primaryDark)
                        .padding(4)
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .padding(.top, 4)
        .background(
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                    .fill(AppColors.surface)
                Rectangle()
                    .fill(AppColors.accentGold.opacity(0.2))
                    .frame(height: 4)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: AppMetrics.cardRadius,
                            topTrailingRadius: AppMetrics.cardRadius
                        )
                    )
            }
        )
        .shadow(color: AppColors.primary.opacity(0.05), radius: 7.5, y: 2)
    }
}

#Preview {
    VerseOfTheDayCard(
        arabicText: "يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
        translation: "\"Ey iman edenler! Sabır ve namazla yardım dileyin. Şüphesiz Allah sabredenlerin yanındadır.\"",
        reference: "Bakara, 153"
    )
    .padding()
    .background(AppColors.background)
}
