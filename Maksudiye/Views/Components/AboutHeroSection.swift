//
//  AboutHeroSection.swift
//  Maksudiye
//

import SwiftUI

struct AboutHeroSection: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HeritagePortrait()
                .frame(maxWidth: .infinity)
                .frame(height: 197)

            LinearGradient(
                colors: [Color.clear, AppColors.primaryDark.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 18))
                    .foregroundStyle(Color(red: 157 / 255, green: 245 / 255, blue: 188 / 255))
                    .lineSpacing(6)
            }
            .padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppMetrics.cardRadius))
        .shadow(color: AppColors.primary.opacity(0.05), radius: 10, y: 4)
    }
}

private struct HeritagePortrait: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 60 / 255, green: 50 / 255, blue: 40 / 255),
                        AppColors.primaryDark
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Path { path in
                    let stepX = w / 12
                    for i in 0 ... 12 {
                        let x = CGFloat(i) * stepX
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: h))
                    }
                    let stepY = h / 6
                    for i in 0 ... 6 {
                        let y = CGFloat(i) * stepY
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: w, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.05), lineWidth: 0.5)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 220 / 255, green: 180 / 255, blue: 130 / 255).opacity(0.5),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .offset(x: -w * 0.18, y: -h * 0.05)

                Path { path in
                    let cx = w * 0.32
                    let cy = h * 0.45
                    path.addEllipse(in: CGRect(x: cx - 28, y: cy - 38, width: 56, height: 56))
                    path.move(to: CGPoint(x: cx - 38, y: cy + 80))
                    path.addQuadCurve(
                        to: CGPoint(x: cx + 38, y: cy + 80),
                        control: CGPoint(x: cx, y: cy + 10)
                    )
                }
                .fill(Color(red: 90 / 255, green: 65 / 255, blue: 50 / 255).opacity(0.7))
            }
        }
    }
}

#Preview {
    AboutHeroSection(
        title: "Hakkımızda",
        subtitle: "Manevi mirası geleceğe taşıyan bir köprü."
    )
    .padding()
    .background(AppColors.background)
}
