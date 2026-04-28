//
//  HistoryTimeline.swift
//  Maksudiye
//

import SwiftUI

struct HistoryEvent: Identifiable {
    let id = UUID()
    let label: String
    let description: String
    var emphasized: Bool = false
}

struct HistoryTimeline: View {
    let title: String
    let events: [HistoryEvent]

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(AppColors.primaryDark)

            VStack(alignment: .leading, spacing: 24) {
                ForEach(events) { event in
                    HistoryRow(event: event)
                }
            }
            .padding(.leading, 34)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(AppColors.primaryDark.opacity(0.2))
                    .frame(width: 2)
                    .padding(.vertical, 16)
            }
        }
    }
}

private struct HistoryRow: View {
    let event: HistoryEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.label)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.primaryDark)

            Text(event.description)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textSecondary)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topLeading) {
            Circle()
                .fill(event.emphasized ? AppColors.primaryDark : AppColors.primary)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle().stroke(AppColors.background, lineWidth: 4)
                )
                .offset(x: -41, y: 2)
        }
    }
}

#Preview {
    HistoryTimeline(
        title: "Vakıf Tarihçesi",
        events: [
            HistoryEvent(
                label: "BAŞLANGIÇ",
                description: "Vakfımız, Maksudiye Mahallesi'nde bir grup hayırseverin bir araya gelmesiyle yerel bir yardımlaşma derneği olarak temellerini attı.",
                emphasized: true
            ),
            HistoryEvent(
                label: "BÜYÜME",
                description: "Eğitim ve sosyal faaliyetlerimizin kapsamı genişletilerek bölgedeki gençler için kurslar ve seminerler başlatıldı."
            ),
            HistoryEvent(
                label: "GÜNÜMÜZ",
                description: "Bugün dijital platformlarımız ve fiziki merkezlerimizle binlerce kişiye manevi rehberlik hizmeti sunan köklü bir kurum haline geldik.",
                emphasized: true
            )
        ]
    )
    .padding()
    .background(AppColors.background)
}
