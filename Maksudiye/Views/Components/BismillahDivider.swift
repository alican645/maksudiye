//
//  BismillahDivider.swift
//  Maksudiye
//

import SwiftUI

struct BismillahDivider: View {
    var body: some View {
        VStack(spacing: 16) {
            HairlineGradient()

            (
                Text("بِسْمِ ").foregroundColor(AppColors.primaryDark)
                    + Text("اللَّهِ").foregroundColor(Color(red: 185 / 255, green: 28 / 255, blue: 28 / 255)).fontWeight(.bold)
                    + Text(" الرَّحْمَنِ الرَّحِيمِ").foregroundColor(AppColors.primaryDark)
            )
            .font(.system(size: 32))
            .multilineTextAlignment(.center)

            HairlineGradient()
        }
        .opacity(0.9)
    }
}

private struct HairlineGradient: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 167 / 255, green: 243 / 255, blue: 208 / 255).opacity(0),
                Color(red: 167 / 255, green: 243 / 255, blue: 208 / 255),
                Color(red: 167 / 255, green: 243 / 255, blue: 208 / 255).opacity(0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: 64, height: 1)
    }
}

#Preview {
    BismillahDivider()
        .padding()
        .background(AppColors.background)
}
