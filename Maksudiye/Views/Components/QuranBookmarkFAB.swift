//
//  QuranBookmarkFAB.swift
//  Maksudiye
//

import SwiftUI

struct QuranBookmarkFAB: View {
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "book.pages")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16).fill(AppColors.accentGold)
                )
                .shadow(color: .black.opacity(0.15), radius: 12, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuranBookmarkFAB()
        .padding()
        .background(AppColors.background)
}
