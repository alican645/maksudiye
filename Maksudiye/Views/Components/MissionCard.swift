//
//  MissionCard.swift
//  Maksudiye
//

import SwiftUI

struct MissionCard: View {
    let title: String
    let text: String
    let badgeTopLine: String
    let badgeBottomLine: String

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    Image(systemName: "target")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(AppColors.primaryDark)
                        .frame(width: 28, height: 28)

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

            MissionFocusBadge(topLine: badgeTopLine, bottomLine: badgeBottomLine)
                .frame(height: 192)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius).fill(AppColors.border)
        )
    }
}

private struct MissionFocusBadge: View {
    let topLine: String
    let bottomLine: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.primaryDeep,
                    AppColors.primaryDark
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            ForEach(0 ..< 3) { i in
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    .frame(width: CGFloat(160 - i * 36), height: CGFloat(160 - i * 36))
            }

            VStack(spacing: 4) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.bottom, 4)

                Text(topLine)
                    .font(.system(size: 14, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(bottomLine)
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(1.0)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    MissionCard(
        title: "Misyonumuz",
        text: "Bireylerin Kur'an-ı Kerim'in ışığında ahlaki ve manevi gelişimlerini desteklemek, toplumsal yardımlaşma bilincini artırmak ve kültürel mirasımızı koruyarak gelecek nesillere aktarmak temel görevimizdir.",
        badgeTopLine: "MISSION FOCUS",
        badgeBottomLine: "SAFE WORK"
    )
    .padding()
    .background(AppColors.background)
}
