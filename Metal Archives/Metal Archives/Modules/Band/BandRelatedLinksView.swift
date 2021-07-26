//
//  BandRelatedLinksView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/07/2021.
//

import SwiftUI

struct BandRelatedLinksView: View {
    @Binding var relatedLinksFetchable: FetchableObject<[RelatedLink]>
    var onRetry: () -> Void

    var body: some View {
        Group {
            switch relatedLinksFetchable {
            case .error(let error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.description)
                        .frame(maxWidth: .infinity)
                        .font(.caption)

                    Button(action: {
                        onRetry()
                    }, label: {
                        Label("Retry", systemImage: "arrow.clockwise")
                    })
                }

            case .fetching, .waiting:
                ProgressView()

            case .fetched(let relatedLinks):
                Text("\(relatedLinks.count)")
            }
        }
    }
}
