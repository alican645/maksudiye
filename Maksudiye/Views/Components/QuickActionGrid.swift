//
//  QuickActionGrid.swift
//  Maksudiye
//

import SwiftUI

struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

struct QuickActionGrid: View {
    let actions: [QuickAction]
    var onSelect: (QuickAction) -> Void = { _ in }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(actions) { action in
                QuickActionTile(action: action) {
                    onSelect(action)
                }
            }
        }
    }
}

private struct QuickActionTile: View {
    let action: QuickAction
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryDark.opacity(0.05))
                        .frame(width: 48, height: 48)
                    Image(systemName: action.icon)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(AppColors.primaryDark)
                }
                Text(action.title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(AppColors.primaryDark)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 114)
            .background(
                RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    QuickActionGrid(actions: [
        QuickAction(title: "Bağış Yap", icon: "heart"),
        QuickAction(title: "Etkinlikler", icon: "calendar"),
        QuickAction(title: "Duyurular", icon: "megaphone"),
        QuickAction(title: "İletişim", icon: "questionmark.circle")
    ])
    .padding()
    .background(AppColors.background)
}
