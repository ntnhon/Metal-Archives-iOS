//
//  BandRelatedLinksView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/07/2021.
//

import SwiftUI

struct BandRelatedLinksView: View {
    @ObservedObject var viewModel: BandViewModel

    var body: some View {
        VStack {
            switch viewModel.relatedLinksFetchable {
            case .error(let error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.userFacingMessage)
                        .frame(maxWidth: .infinity)
                        .font(.caption)

                    RetryButton {
                        Task { await viewModel.refreshRelatedLinks(force: true) }
                    }
                }

            case .fetching:
                ProgressView()

            case .fetched(let relatedLinks):
                if relatedLinks.isEmpty {
                    Text("No related links yet")
                        .font(.callout.italic())
                } else {
                    ForEach(relatedLinks, id: \.urlString) {
                        RelatedLinkView(relatedLink: $0)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        Divider()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.refreshRelatedLinks(force: false)
            }
        }
    }
}
