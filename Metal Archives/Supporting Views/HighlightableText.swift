//
//  HighlightTextView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/09/2021.
//

import SwiftUI

private extension HighlightableText {
    enum Content {
        case normal(String)
        case highlight(String)
    }
}

struct HighlightableText: View {
    private let contents: [Content]
    private let highlightFontWeight: Font.Weight
    private let highlightColor: Color

    init(text: String,
         highlights: [String],
         highlightFontWeight: Font.Weight,
         highlightColor: Color) {
        let separator = UUID().uuidString
        var text = text
        highlights.forEach {
            text = text.replacingOccurrences(of: $0, with: "\(separator)\($0)\(separator)" )
        }
        let rawContents = text.components(separatedBy: separator)
        contents = rawContents.map {
            if highlights.contains($0) {
                return Content.highlight($0)
            }
            return Content.normal($0)
        }
        self.highlightFontWeight = highlightFontWeight
        self.highlightColor = highlightColor
    }

    var body: some View {
        contents.map { textContent in
            switch textContent {
            case .normal(let content):
                return Text(content)
            case .highlight(let content):
                return Text(content)
                    .fontWeight(highlightFontWeight)
                    .foregroundColor(highlightColor)
            }
        }.reduce(Text(""), +)
    }
}

struct HighlightTextView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next line_length
        HighlightableText(text: "(R.I.P. 2001) See also: ex-Control Denied, ex-Mantas, ex-Slaughter, ex-Voodoocult",
                          highlights: ["Control Denied", "Mantas", "Slaughter", "Voodoocult"],
                          highlightFontWeight: .bold,
                          highlightColor: .accentColor)
    }
}
