//
//  ArtistRelatedLinksView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 02/11/2022.
//

import SwiftUI

struct ArtistRelatedLinksView: View {
    @ObservedObject var viewModel: ArtistViewModel

    var body: some View {
        VStack {
            switch viewModel.relatedLinksFetchable {
            case .error(let error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.userFacingMessage)
                        .frame(maxWidth: .infinity)
                        .font(.caption)

                    RetryButton {
                        Task { await viewModel.fetchRelatedLinks(forceRefresh: true) }
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
                await viewModel.fetchRelatedLinks(forceRefresh: false)
            }
        }
    }
}
