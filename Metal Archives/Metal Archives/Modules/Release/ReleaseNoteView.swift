//
//  ReleaseNoteView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 11/10/2022.
//

import SwiftUI

struct ReleaseNoteView: View {
    let note: String?

    init(release: Release) {
        self.note = release.additionalHtmlNote?.strippedHtmlString()
    }

    var body: some View {
        if let note = note {
            Text(note)
                .textSelection(.enabled)
        } else {
            Text("No additional notes")
                .font(.callout.italic())
        }
    }
}
