//
//  PrayerTimesList.swift
//  Maksudiye
//

import SwiftUI

struct PrayerTime: Identifiable {
    let id = UUID()
    let name: String
    let time: String
    let icon: String
    var isActive: Bool = false
}

struct PrayerTimesList: View {
    let location: String
    let prayers: [PrayerTime]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Günlük Vakitler")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.primaryDark)
                Spacer()
                Text(location)
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(0.6)
                    .foregroundStyle(AppColors.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .overlay(alignment: .bottom) {
                Rectangle().fill(AppColors.border).frame(height: 1)
            }

            ForEach(Array(prayers.enumerated()), id: \.element.id) { index, prayer in
                PrayerRow(prayer: prayer)
                    .background(
                        prayer.isActive
                            ? LinearGradient(
                                colors: [Color.white, AppColors.highlightTint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(colors: [Color.white], startPoint: .top, endPoint: .bottom)
                    )

                if index < prayers.count - 1 {
                    Rectangle().fill(AppColors.border).frame(height: 1)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius).fill(AppColors.surface)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppMetrics.cardRadius))
        .shadow(color: AppColors.primary.opacity(0.05), radius: 15, y: 2)
    }
}

private struct PrayerRow: View {
    let prayer: PrayerTime

    var body: some View {
        HStack {
            HStack(spacing: 16) {
                Image(systemName: prayer.icon)
                    .font(.system(size: 16, weight: prayer.isActive ? .bold : .regular))
                    .foregroundStyle(prayer.isActive ? AppColors.primaryDark : AppColors.textSecondary)
                    .frame(width: 22, height: 22)

                Text(prayer.name)
                    .font(.system(size: 16, weight: prayer.isActive ? .bold : .semibold))
                    .foregroundStyle(prayer.isActive ? AppColors.primaryDark : AppColors.textPrimary)
            }
            Spacer()
            Text(prayer.time)
                .font(.system(size: 16, weight: prayer.isActive ? .bold : .regular))
                .foregroundStyle(prayer.isActive ? AppColors.primaryDark : AppColors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

#Preview {
    PrayerTimesList(
        location: "Ankara, TR",
        prayers: [
            PrayerTime(name: "İmsak", time: "05:42", icon: "sunrise"),
            PrayerTime(name: "Güneş", time: "07:12", icon: "sun.max"),
            PrayerTime(name: "Öğle", time: "13:12", icon: "sun.max.fill", isActive: true),
            PrayerTime(name: "İkindi", time: "16:45", icon: "sun.haze"),
            PrayerTime(name: "Akşam", time: "19:32", icon: "sunset"),
            PrayerTime(name: "Yatsı", time: "21:05", icon: "moon.stars")
        ]
    )
    .padding()
    .background(AppColors.background)
}
