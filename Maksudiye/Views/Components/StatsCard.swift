//
//  StatsCard.swift
//  Maksudiye
//

import SwiftUI

struct StatsCard: View {
    let label: String
    let value: String
    let footnote: String

    var body: some View {
        VStack(spacing: 16) {
            Text(label)
                .font(.system(size: 16))
                .tracking(1.6)
                .foregroundStyle(.white.opacity(0.8))

            Text(value)
                .font(.system(size: 40, weight: .semibold, design: .serif))
                .foregroundStyle(.white)

            Rectangle()
                .fill(.white.opacity(0.2))
                .frame(width: 64, height: 1)

            Text(footnote)
                .font(.system(size: 16))
                .foregroundStyle(Color(red: 157 / 255, green: 245 / 255, blue: 188 / 255))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius).fill(AppColors.primary)
        )
    }
}

#Preview {
    StatsCard(
        label: "KURULUŞ",
        value: "1994",
        footnote: "Çeyrek asrı aşkın bir süredir vakıf geleneğimizi sürdürüyoruz."
    )
    .padding()
    .background(AppColors.background)
}
