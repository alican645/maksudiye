//
//  ContentView.swift
//  Maksudiye
//
//  Created by Ali Can on 28.04.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: BottomTab = .home
    @StateObject private var prayerViewModel = PrayerTimesViewModel()
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.background.ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:
                    HomeView(viewModel: prayerViewModel)
                case .quran:
                    QuranView()
                case .about:
                    AboutView()
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                TopAppBar(
                    leading: leading(for: selectedTab),
                    actions: actions(for: selectedTab),
                    onLeadingTap: handleLeadingTap
                )
            }

            switch selectedTab {
            case .home:
                ContextualSupportButton()
                    .padding(.trailing, 24)
                    .padding(.bottom, 96)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            case .quran:
                QuranBookmarkFAB()
                    .padding(.trailing, 24)
                    .padding(.bottom, 96)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            case .about:
                EmptyView()
            }

            BottomNavBar(selected: $selectedTab)
                .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: prayerViewModel)
        }
    }

    private func leading(for tab: BottomTab) -> TopAppBarLeading {
        tab == .home ? .menu : .back
    }

    private func actions(for tab: BottomTab) -> [TopAppBarAction] {
        switch tab {
        case .home:
            return [
                TopAppBarAction(icon: "bell", action: {}),
                TopAppBarAction(icon: "gearshape", action: { showSettings = true })
            ]
        case .quran:
            return [
                TopAppBarAction(icon: "magnifyingglass", action: {}),
                TopAppBarAction(icon: "gearshape", action: { showSettings = true })
            ]
        case .about:
            return []
        }
    }

    private func handleLeadingTap() {
        if selectedTab != .home {
            selectedTab = .home
        }
    }
}

private struct ContextualSupportButton: View {
    var body: some View {
        Button {
            // TODO: open support
        } label: {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Circle().fill(AppColors.primary))
                .shadow(color: .black.opacity(0.2), radius: 12, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
