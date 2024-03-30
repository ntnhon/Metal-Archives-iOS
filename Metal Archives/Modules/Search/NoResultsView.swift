//
//  NoResultsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import SwiftUI

struct NoResultsView: View {
    @Environment(\.dismiss) private var dismiss
    let message: String

    init(query: String?) {
        if let query {
            message = "🤕 No results found for \"\(query)\""
        } else {
            message = "🤕 No results found"
        }
    }

    var body: some View {
        VStack {
            Text(message)
                .font(.callout.italic())
                .multilineTextAlignment(.center)
            Button(action: dismiss.callAsFunction) {
                Label("Go back", systemImage: "arrowshape.turn.up.backward.2")
            }
        }
        .padding()
    }
}
