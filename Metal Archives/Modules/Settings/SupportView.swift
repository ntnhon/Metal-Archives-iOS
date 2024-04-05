//
//  SupportView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var preferences: Preferences

    var body: some View {
        NavigationView {
            ScrollView {
                Text(AttributedString(markdownFileName: "Support"))
            }
            .padding(.horizontal)
            .navigationBarTitle("Support this effort")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .openUrlsWithInAppSafari(controlTintColor: preferences.theme.primaryColor)
    }
}

#Preview {
    SupportView()
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
}
