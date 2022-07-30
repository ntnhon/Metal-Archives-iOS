//
//  AdvancedSearchTipsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/06/2021.
//

import SwiftUI

struct AdvancedSearchTipsView: View {
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                Text(tips())
                    .padding(.horizontal)
                    .navigationTitle("Search tips")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: dismiss.callAsFunction) {
                                Image(systemName: "xmark")
                            }
                        }
                    }
            }
            .accentColor(preferences.theme.primaryColor)
        }
        .colorScheme(.dark)
    }

    private func tips() -> AttributedString {
        typealias Options = AttributedString.MarkdownParsingOptions
        let options = Options(allowsExtendedAttributes: true,
                              interpretedSyntax: .inlineOnlyPreservingWhitespace,
                              failurePolicy: .returnPartiallyParsedIfPossible,
                              languageCode: nil)
        guard let path = Bundle.main.url(forResource: "SearchTips", withExtension: "md"),
              let string = try? String(contentsOf: path),
              var attributedString = try? AttributedString(markdown: string,
                                                           options: options) else {
            return .init(stringLiteral: "???")
        }

        let primaryColor = preferences.theme.primaryColor

        let headlines = ["Keyword matching",
                         "Multiple keywords",
                         "Searching phrases",
                         "Wildcards",
                         "Excluding keywords",
                         "Boolean operators"]
        for headline in headlines {
            if let range = attributedString.range(of: headline) {
                attributedString[range].font = .headline.weight(.bold)
                attributedString[range].foregroundColor = primaryColor
            }
        }

        if let advancedSearchRange = attributedString.range(of: "Advanced Search") {
            attributedString[advancedSearchRange].font = .title.weight(.bold)
            attributedString[advancedSearchRange].foregroundColor = primaryColor
        }
        return attributedString
    }
}

struct AdvancedSearchTipsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSearchTipsView()
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}
