//
//  HomeView.swift
//  Maksudiye
//

import SwiftUI

struct HomeView: View {
    private let prayers: [PrayerTime] = [
        PrayerTime(name: "İmsak", time: "05:42", icon: "sunrise"),
        PrayerTime(name: "Güneş", time: "07:12", icon: "sun.max"),
        PrayerTime(name: "Öğle", time: "13:12", icon: "sun.max.fill", isActive: true),
        PrayerTime(name: "İkindi", time: "16:45", icon: "sun.haze"),
        PrayerTime(name: "Akşam", time: "19:32", icon: "sunset"),
        PrayerTime(name: "Yatsı", time: "21:05", icon: "moon.stars")
    ]

    private let quickActions: [QuickAction] = [
        QuickAction(title: "Bağış Yap", icon: "heart"),
        QuickAction(title: "Etkinlikler", icon: "calendar"),
        QuickAction(title: "Duyurular", icon: "megaphone"),
        QuickAction(title: "İletişim", icon: "questionmark.circle")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppMetrics.sectionSpacing) {
                NextPrayerCard(
                    prayerName: "Öğle",
                    time: "13:12",
                    remaining: "02:45:12"
                )

                PrayerTimesList(location: "Ankara, TR", prayers: prayers)

                VerseOfTheDayCard(
                    arabicText: "يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
                    translation: "\"Ey iman edenler! Sabır ve namazla yardım dileyin. Şüphesiz Allah sabredenlerin yanındadır.\"",
                    reference: "Bakara, 153"
                )

                CharitableActionCard(
                    title: "Vakıf Çalışmaları",
                    subtitle: "Eğitim ve yardım projelerimize destek olun."
                )
                .frame(height: 180)

                QuickActionGrid(actions: quickActions)
            }
            .padding(.horizontal, AppMetrics.pageHorizontalPadding)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .background(AppColors.background)
    }
}

#Preview {
    HomeView()
}
