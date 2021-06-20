//
//  DiscographyModeView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

struct DiscographyModeView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var settings: Settings

    var body: some View {
        Form {
            ForEach(DiscographyMode.allCases, id: \.self) { mode in
                Button(action: {
                    settings.$discographyMode.wrappedValue = mode
                    settings.objectWillChange.send()
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack {
                        Text(mode.description)
                            .foregroundColor(.primary)
                        if settings.discographyMode == mode {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                })
            }
        }
        .navigationTitle("Default discography mode")
    }
}

struct DiscographyModeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DiscographyModeView()
                .environmentObject(Settings())
        }
    }
}
