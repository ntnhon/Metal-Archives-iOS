//
//  SupportView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) var dismiss

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
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}