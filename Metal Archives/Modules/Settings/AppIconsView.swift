//
//  AppIconsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/04/2024.
//

import SwiftUI

struct AppIconsView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var selectedIcon: AlternateAppIcon?
    var body: some View {
        Form {
            mainIconSection
            customIconsSection
        }
        .navigationTitle("App icon")
        .animation(.default, value: UIApplication.shared.alternateIconName)
        .tint(preferences.theme.primaryColor)
        .task {
            selectedIcon = .init(iconName: UIApplication.shared.alternateIconName)
        }
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
        selectedIcon = icon
    }
}

private extension AppIconsView {
    @ViewBuilder
    var mainIconSection: some View {
        Section(content: {
            HStack {
                iconThumbnail(.primary)
                Spacer()
                if selectedIcon == .primary {
                    checkmark
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                select(.primary)
            }
        }, footer: {
            Text("Designed by **[Matt Stewart](https://twitter.com/nrthrndarkness)**")
        })
    }
}

private extension AppIconsView {
    var customIconsSection: some View {
        Section {
            ForEach(AlternateAppIcon.customIcons, id: \.self) { icon in
                HStack {
                    iconThumbnail(icon)
                    Spacer()
                    if selectedIcon == icon {
                        checkmark
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    select(icon)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AppIconsView()
            .environmentObject(Preferences())
            .preferredColorScheme(.dark)
    }
}
