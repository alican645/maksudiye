//
//  SurahSelectorPill.swift
//  Maksudiye
//

import SwiftUI

struct SurahSelectorPill: View {
    let suraNumber: Int
    let suraName: String
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text("SURA \(suraNumber)")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AppColors.primaryDark)

                Circle()
                    .fill(Color(red: 167 / 255, green: 243 / 255, blue: 208 / 255))
                    .frame(width: 4, height: 4)

                Text(suraName)
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.primaryDark)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.primaryDark)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                Capsule().fill(Color(red: 242 / 255, green: 244 / 255, blue: 242 / 255))
            )
            .overlay(
                Capsule().stroke(
                    Color(red: 209 / 255, green: 250 / 255, blue: 229 / 255).opacity(0.5),
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SurahSelectorPill(suraNumber: 18, suraName: "Al-Kahf")
        .padding()
        .background(AppColors.background)
}
