//
//  AttributedStringExtensions.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 02/08/2022.
//

import SwiftUI

private typealias MarkdownParsingOptions = AttributedString.MarkdownParsingOptions

extension AttributedString {
    init(markdownFileName: String) {
        let options = MarkdownParsingOptions(allowsExtendedAttributes: true,
                                             interpretedSyntax: .inlineOnlyPreservingWhitespace,
                                             failurePolicy: .returnPartiallyParsedIfPossible,
                                             languageCode: nil)
        guard let path = Bundle.main.url(forResource: markdownFileName, withExtension: "md"),
              let string = try? String(contentsOf: path),
              let attributedString = try? AttributedString(markdown: string, options: options) else {
            self = .init(stringLiteral: "???")
            return
        }
        self = attributedString
    }
}
