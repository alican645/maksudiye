//
//  InfoCard.swift
//  Maksudiye
//

import SwiftUI

struct InfoCard: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.primaryDark)
                    .frame(width: 28, height: 19)

                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.primaryDark)
            }

            Text(text)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(10)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius).fill(AppColors.surface)
        )
        .shadow(color: AppColors.primary.opacity(0.03), radius: 7.5, y: 2)
    }
}

#Preview {
    InfoCard(
        icon: "eye",
        title: "Vizyonumuz",
        text: "Maksudiye Vakfı olarak temel vizyonumuz, kadim İslami değerleri modern hayatın dinamikleriyle harmanlayarak, toplumun her kesimine ulaşan sürdürülebilir bir manevi rehberlik ekosistemi oluşturmaktır."
    )
    .padding()
    .background(AppColors.background)
}
