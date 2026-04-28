//
//  BottomNavBar.swift
//  Maksudiye
//

import SwiftUI

enum BottomTab: String, CaseIterable, Identifiable {
    case home, quran, about

    var id: String { rawValue }

    var label: String {
        switch self {
        case .home: "Namaz Vakitleri"
        case .quran: "Kur'an-ı Kerim"
        case .about: "Hakkımızda"
        }
    }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .quran: "book.fill"
        case .about: "info.circle"
        }
    }
}

struct BottomNavBar: View {
    @Binding var selected: BottomTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(BottomTab.allCases) { tab in
                Button {
                    selected = tab
                } label: {
                    BottomNavItem(tab: tab, isSelected: tab == selected)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 80)
        .background(
            Color.white.opacity(0.95)
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .top) {
            Rectangle().fill(AppColors.borderSoft).frame(height: 1)
        }
        .shadow(color: AppColors.primary.opacity(0.04), radius: 10, y: -4)
    }
}

private struct BottomNavItem: View {
    let tab: BottomTab
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: tab.icon)
                .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? AppColors.primaryActive : AppColors.textDisabled)
                .frame(height: 20)

            Text(tab.label)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.55)
                .foregroundStyle(isSelected ? AppColors.primaryActive : AppColors.textDisabled)

            Circle()
                .fill(isSelected ? AppColors.primaryActive : Color.clear)
                .frame(width: 4, height: 4)
                .padding(.top, -2)
        }
    }
}

#Preview {
    StatePreview()
}

private struct StatePreview: View {
    @State private var tab: BottomTab = .home
    var body: some View {
        VStack {
            Spacer()
            BottomNavBar(selected: $tab)
        }
        .background(AppColors.background)
    }
}
