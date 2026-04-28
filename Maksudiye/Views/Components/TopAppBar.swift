//
//  TopAppBar.swift
//  Maksudiye
//

import SwiftUI

enum TopAppBarLeading {
    case menu
    case back
}

struct TopAppBarAction: Identifiable {
    let id = UUID()
    let icon: String
    let action: () -> Void
}

struct TopAppBar: View {
    var leading: TopAppBarLeading = .menu
    var actions: [TopAppBarAction] = []
    var onLeadingTap: () -> Void = {}

    var body: some View {
        HStack {
            HStack(spacing: 16) {
                Button(action: onLeadingTap) {
                    Image(systemName: leading == .menu ? "line.3.horizontal" : "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.primaryDeep)
                }
                Text("Maksudiye Vakfı")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.primaryDeep)
            }
            Spacer()
            HStack(spacing: 8) {
                ForEach(actions) { action in
                    Button(action: action.action) {
                        Image(systemName: action.icon)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(width: 36, height: 36)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 64)
        .background(
            Color.white.opacity(0.92)
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppColors.borderSoft.opacity(0.5))
                .frame(height: 1)
        }
        .shadow(color: AppColors.primary.opacity(0.05), radius: 7.5, y: 2)
    }
}

#Preview {
    VStack(spacing: 0) {
        TopAppBar(actions: [TopAppBarAction(icon: "bell", action: {})])
        Spacer()
    }
    .background(AppColors.background)
}
