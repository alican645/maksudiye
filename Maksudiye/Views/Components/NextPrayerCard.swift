//
//  NextPrayerCard.swift
//  Maksudiye
//

import SwiftUI

struct NextPrayerCard: View {
    let prayerName: String
    let time: String
    let remaining: String
    var onAction: () -> Void = {}

    var body: some View {
        ZStack(alignment: .topTrailing) {
            DecorativeMosqueShape()
                .stroke(Color.white.opacity(0.18), lineWidth: 1.5)
                .frame(width: 152, height: 132)
                .padding(.trailing, 8)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 8) {
                Text("SIRADAKI NAMAZ")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.8))

                Text(prayerName)
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(time)
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                    Text("kalan süre \(remaining)")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(0.6)
                        .foregroundStyle(.white.opacity(0.9))
                }

                Button(action: onAction) {
                    Text("Vakitleri İncele")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(AppColors.primaryDark)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(Color.white)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 6, y: 4)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                .fill(AppColors.primary)
        )
        .shadow(color: .black.opacity(0.1), radius: 15, y: 10)
    }
}

private struct DecorativeMosqueShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Three arches representing mosque silhouette
        let archWidth = w / 3
        for i in 0 ..< 3 {
            let x = CGFloat(i) * archWidth
            path.move(to: CGPoint(x: x, y: h))
            path.addLine(to: CGPoint(x: x, y: h * 0.55))
            path.addQuadCurve(
                to: CGPoint(x: x + archWidth, y: h * 0.55),
                control: CGPoint(x: x + archWidth / 2, y: h * 0.2)
            )
            path.addLine(to: CGPoint(x: x + archWidth, y: h))
        }

        // Crescent on top
        let crescentRect = CGRect(x: w / 2 - 10, y: 0, width: 20, height: 20)
        path.addEllipse(in: crescentRect)

        return path
    }
}

#Preview {
    NextPrayerCard(prayerName: "Öğle", time: "13:12", remaining: "02:45:12")
        .padding()
        .background(AppColors.background)
}
