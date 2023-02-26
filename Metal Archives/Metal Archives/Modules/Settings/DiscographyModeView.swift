//
//  DiscographyModeView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

struct DiscographyModeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var preferences: Preferences

    var body: some View {
        Form {
            ForEach(DiscographyMode.allCases, id: \.self) { mode in
                Button(action: {
                    preferences.$discographyMode.wrappedValue = mode
                    preferences.objectWillChange.send()
                    dismiss()
                }, label: {
                    HStack {
                        Text(mode.description)
                            .foregroundColor(.primary)
                        if preferences.discographyMode == mode {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                })
            }
        }
        .navigationBarTitle("Default discography mode", displayMode: .inline)
    }
}

struct DiscographyModeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DiscographyModeView()
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
