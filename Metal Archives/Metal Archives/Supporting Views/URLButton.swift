//
//  URLButton.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct URLButton<Content: View>: View {
    @Environment(\.openURL) private var openURL
    let urlString: String
    let content: Content

    init(urlString: String, @ViewBuilder content: () -> Content) {
        self.urlString = urlString
        self.content = content()
    }

    var body: some View {
        Button(action: {
            if let url = URL(string: urlString) {
                openURL(url)
            }
        }, label: {
            content
        })
        .foregroundColor(.primary)
    }
}

struct URLButton_Previews: PreviewProvider {
    static var previews: some View {
        URLButton(urlString: "http://example.com") {
            Text("Example")
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
