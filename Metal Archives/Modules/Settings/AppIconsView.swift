//
//  AppIconsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/04/2024.
//

import SwiftUI

struct AppIconsView: View {
    @EnvironmentObject private var preferences: Preferences
    var body: some View {
        Form {
            mainIconSection
        }
        .navigationTitle("App icon")
        .animation(.default, value: UIApplication.shared.alternateIconName)
        .tint(preferences.theme.primaryColor)
    }
}

private extension AppIconsView {
    @ViewBuilder
    func iconThumbnail(_ icon: AlternateAppIcon) -> some View {
        if let uiImage = UIImage(named: icon.iconName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 64)
                .cornerRadius(12)
        }
    }

    var checkmark: some View {
        Label("", systemImage: "checkmark")
            .foregroundStyle(preferences.theme.primaryColor)
    }

    func select(_ icon: AlternateAppIcon) {
        UIApplication.shared.setAlternateIconName(icon.value)
    }
}

private extension AppIconsView {
    @ViewBuilder
    var mainIconSection: some View {
        Section(content: {
            HStack {
                iconThumbnail(.primary)
                Spacer()
                if UIApplication.shared.alternateIconName == nil {
                    checkmark
                }
            }
        }, footer: {
            Text("Designed by **[Matt Stewart](https://twitter.com/nrthrndarkness)**")
        })
    }
}

#Preview {
    NavigationView {
        AppIconsView()
            .environmentObject(Preferences())
            .preferredColorScheme(.dark)
    }
}
