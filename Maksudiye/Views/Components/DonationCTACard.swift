//
//  DonationCTACard.swift
//  Maksudiye
//

import SwiftUI

struct DonationCTACard: View {
    let title: String
    let message: String
    var onDonate: () -> Void = {}

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hands.and.sparkles.fill")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 41)

            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 320)

            Button(action: onDonate) {
                HStack(spacing: 16) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.accentGold)
                    Text("Bağış Yap")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.accentGold)
                }
                .padding(.horizontal, 48)
                .padding(.vertical, 16)
                .background(
                    Capsule().fill(Color(red: 254 / 255, green: 214 / 255, blue: 91 / 255))
                )
                .shadow(color: .black.opacity(0.1), radius: 10, y: 6)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                .fill(
                    LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: AppColors.primary.opacity(0.15), radius: 12, y: 10)
    }
}

#Preview {
    DonationCTACard(
        title: "Hayırlara Vesile Olun",
        message: "Vakfımızın eğitim ve yardım faaliyetlerine katkıda bulunarak, bir talebenin yetişmesine veya bir ihtiyaç sahibinin yüzünün gülmesine vesile olabilirsiniz."
    )
    .padding()
    .background(AppColors.background)
}
