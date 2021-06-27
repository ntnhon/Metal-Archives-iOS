//
//  AboutView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

// swiftlint:disable line_length
private let kAboutString = """
    This application is an unofficial iOS version of Metal Archives website. It is made with 🤘 by a metalhead for metalheads.

    If you encounter any issue related to the content, you can contact the webmaster (see Official Links section).

    If you encounter any issue related to this application's functionalities (crashes, bugs or feature requests), you can reach out the author (see Mobile Application Links section).

    This application is open source on Github, contributions are welcome 🤘.
    """
// swiftlint:enable line_length

struct AboutView: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                Text(kAboutString)
                .padding(.top, 20)
            }
            .padding([.horizontal])
            .navigationBarItems(trailing:
                                    Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }, label: {
                                        Image(systemName: "xmark")
                                    })
            )
            .navigationBarTitle("About this app")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}
