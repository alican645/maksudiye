//
//  ContactSection.swift
//  Maksudiye
//

import SwiftUI

struct ContactSection: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 48) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Bize Ulaşın")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.primaryDark)

                Text("Soru, görüş ve önerileriniz için bizimle dilediğiniz zaman iletişime geçebilirsiniz.")
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 16) {
                    ContactRow(icon: "mappin.and.ellipse", text: "Maksudiye Mah. Merkez Sk. No:12, Ankara")
                    ContactRow(icon: "phone.fill", text: "+90 212 555 00 00")
                    ContactRow(icon: "envelope", text: "info@maksudiye.org.tr")
                }
            }

            VStack(spacing: 16) {
                FormField(label: "Adınız Soyadınız", placeholder: "İsim Giriniz", text: $name)
                FormField(label: "E-Posta Adresi", placeholder: "example@mail.com", text: $email)
                FormField(
                    label: "Mesajınız",
                    placeholder: "Size nasıl yardımcı olabiliriz?",
                    text: $message,
                    isMultiline: true
                )

                Button {
                    // TODO: submit form
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("Mesaj Gönder")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(AppColors.primaryDark)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 8).fill(AppColors.surface)
            )
            .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                .fill(Color(red: 242 / 255, green: 244 / 255, blue: 242 / 255))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius)
                .stroke(Color(red: 190 / 255, green: 201 / 255, blue: 190 / 255).opacity(0.3))
        )
    }
}

private struct ContactRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(AppColors.primaryDark)
                .frame(width: 20)
                .padding(.top, 4)

            Text(text)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }
}

private struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isMultiline: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textSecondary)

            if isMultiline {
                TextEditor(text: $text)
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(height: 96)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(AppColors.border)
                    )
                    .overlay(alignment: .topLeading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.system(size: 16))
                                .foregroundStyle(Color(red: 107 / 255, green: 114 / 255, blue: 128 / 255))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(AppColors.border)
                    )
            }
        }
    }
}

#Preview {
    ContactSection()
        .padding()
        .background(AppColors.background)
}
