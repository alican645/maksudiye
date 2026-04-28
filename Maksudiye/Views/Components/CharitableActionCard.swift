//
//  CharitableActionCard.swift
//  Maksudiye
//

import SwiftUI

struct CharitableActionCard: View {
    let title: String
    let subtitle: String
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                MosqueIllustration()
                    .aspectRatio(16 / 9, contentMode: .fill)
                    .frame(maxWidth: .infinity)

                LinearGradient(
                    colors: [Color.clear, AppColors.primaryDark.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(0.6)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppMetrics.cardRadius))
            .shadow(color: .black.opacity(0.1), radius: 6, y: 4)
        }
        .buttonStyle(.plain)
    }
}

private struct MosqueIllustration: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        AppColors.primaryDark,
                        AppColors.primary.opacity(0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Path { path in
                    let columnWidth = w / 6
                    for i in 0 ..< 6 {
                        let x = CGFloat(i) * columnWidth + columnWidth / 2
                        path.move(to: CGPoint(x: x - 2, y: h * 0.3))
                        path.addLine(to: CGPoint(x: x - 2, y: h))
                        path.addLine(to: CGPoint(x: x + 2, y: h))
                        path.addLine(to: CGPoint(x: x + 2, y: h * 0.3))
                        path.addQuadCurve(
                            to: CGPoint(x: x - 2, y: h * 0.3),
                            control: CGPoint(x: x, y: h * 0.2)
                        )
                    }
                }
                .fill(Color.white.opacity(0.12))

                Path { path in
                    for i in 0 ..< 5 {
                        let columnWidth = w / 6
                        let x = CGFloat(i) * columnWidth + columnWidth
                        path.move(to: CGPoint(x: x - columnWidth * 0.4, y: h * 0.3))
                        path.addQuadCurve(
                            to: CGPoint(x: x + columnWidth * 0.4, y: h * 0.3),
                            control: CGPoint(x: x, y: h * 0.05)
                        )
                    }
                }
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
            }
        }
    }
}

#Preview {
    CharitableActionCard(
        title: "Vakıf Çalışmaları",
        subtitle: "Eğitim ve yardım projelerimize destek olun."
    )
    .padding()
    .background(AppColors.background)
}
