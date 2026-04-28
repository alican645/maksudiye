//
//  AboutView.swift
//  Maksudiye
//

import SwiftUI

struct AboutView: View {
    private let historyEvents: [HistoryEvent] = [
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

    var body: some View {
        ScrollView {
            VStack(spacing: 48) {
                AboutHeroSection(
                    title: "Hakkımızda",
                    subtitle: "Manevi mirası geleceğe taşıyan bir köprü."
                )

                VStack(spacing: 24) {
                    InfoCard(
                        icon: "eye",
                        title: "Vizyonumuz",
                        text: "Maksudiye Vakfı olarak temel vizyonumuz, kadim İslami değerleri modern hayatın dinamikleriyle harmanlayarak, toplumun her kesimine ulaşan sürdürülebilir bir manevi rehberlik ekosistemi oluşturmaktır. Bilgiyle aydınlanan, hikmetle derinleşen bir nesil için çalışıyoruz."
                    )

                    StatsCard(
                        label: "KURULUŞ",
                        value: "1994",
                        footnote: "Çeyrek asrı aşkın bir süredir vakıf geleneğimizi sürdürüyoruz."
                    )

                    MissionCard(
                        title: "Misyonumuz",
                        text: "Bireylerin Kur'an-ı Kerim'in ışığında ahlaki ve manevi gelişimlerini desteklemek, toplumsal yardımlaşma bilincini artırmak ve kültürel mirasımızı koruyarak gelecek nesillere aktarmak temel görevimizdir. Şeffaflık ve samimiyet ilkelerimizden ödün vermeden hizmet ediyoruz.",
                        badgeTopLine: "MISSION FOCUS",
                        badgeBottomLine: "SAFE WORK"
                    )
                }

                HistoryTimeline(title: "Vakıf Tarihçesi", events: historyEvents)

                ContactSection()

                DonationCTACard(
                    title: "Hayırlara Vesile Olun",
                    message: "Vakfımızın eğitim ve yardım faaliyetlerine katkıda bulunarak, bir talebenin yetişmesine veya bir ihtiyaç sahibinin yüzünün gülmesine vesile olabilirsiniz."
                )
            }
            .padding(.horizontal, AppMetrics.pageHorizontalPadding)
            .padding(.top, 32)
            .padding(.bottom, 128)
        }
        .background(AppColors.background)
    }
}

#Preview {
    AboutView()
}
