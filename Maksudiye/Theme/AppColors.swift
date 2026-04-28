//
//  AppColors.swift
//  Maksudiye
//

import SwiftUI

enum AppColors {
    static let primary = Color(red: 0 / 255, green: 107 / 255, blue: 62 / 255)
    static let primaryDark = Color(red: 0 / 255, green: 80 / 255, blue: 45 / 255)
    static let primaryDeep = Color(red: 6 / 255, green: 95 / 255, blue: 70 / 255)
    static let primaryActive = Color(red: 4 / 255, green: 120 / 255, blue: 87 / 255)

    static let surface = Color.white
    static let background = Color(red: 248 / 255, green: 250 / 255, blue: 248 / 255)
    static let highlightTint = Color(red: 240 / 255, green: 247 / 255, blue: 244 / 255)

    static let textPrimary = Color(red: 25 / 255, green: 28 / 255, blue: 27 / 255)
    static let textSecondary = Color(red: 63 / 255, green: 73 / 255, blue: 65 / 255)
    static let textMuted = Color(red: 111 / 255, green: 122 / 255, blue: 112 / 255)
    static let textDisabled = Color(red: 161 / 255, green: 161 / 255, blue: 170 / 255)

    static let border = Color(red: 236 / 255, green: 238 / 255, blue: 236 / 255)
    static let borderSoft = Color(red: 236 / 255, green: 253 / 255, blue: 245 / 255)

    static let accentGold = Color(red: 115 / 255, green: 92 / 255, blue: 0 / 255)
}

enum AppMetrics {
    static let cardRadius: CGFloat = 12
    static let pageHorizontalPadding: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 16
}
