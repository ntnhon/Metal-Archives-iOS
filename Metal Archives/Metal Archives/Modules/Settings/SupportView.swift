//
//  SupportView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

// swiftlint:disable line_length
private let kSupportSiteString = """
    This app and the site are brought to you for free with no ads.

    However, moderating and server maintenance do cost money and personal time. So if you'd like to support the site, you can find more information about how to support them here:
    """

private let kSupportAuthorString = """

    If you already support the webmaster crew and also want to support the author of this application, you can buy him a 🍺  or a cup of ☕ via Paypal:
    """
// swiftlint:enable line_length

struct SupportView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(kSupportSiteString)
                    URLButton(urlString: "https://www.metal-archives.com/content/support") {
                        Text("https://www.metal-archives.com/content/support")
                            .foregroundColor(.accentColor)
                    }

                    Spacer()

                    Text(kSupportAuthorString)
                    URLButton(urlString: "https://paypal.me/ntnhon") {
                        Text("https://paypal.me/ntnhon")
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.top, 20)
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
