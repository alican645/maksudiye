//
//  QuranPaginationBar.swift
//  Maksudiye
//

import SwiftUI

struct QuranPaginationBar: View {
    let currentPage: Int
    let totalPages: Int
    var onPrevious: () -> Void = {}
    var onNext: () -> Void = {}

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .bold))
                    Text("Geri")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(AppColors.primaryDark)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                        .fill(Color(red: 242 / 255, green: 244 / 255, blue: 242 / 255))
                )
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Sayfa \(currentPage) / \(totalPages)")
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            Button(action: onNext) {
                HStack(spacing: 8) {
                    Text("İleri")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                        .fill(AppColors.primaryDark)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    QuranPaginationBar(currentPage: 293, totalPages: 604)
        .padding()
        .background(AppColors.background)
}
