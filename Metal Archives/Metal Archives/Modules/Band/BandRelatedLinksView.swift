//
//  BandRelatedLinksView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/07/2021.
//

import SwiftUI

struct BandRelatedLinksView: View {
    @EnvironmentObject private var viewModel: BandViewModel

    var body: some View {
        Group {
            switch viewModel.relatedLinksFetchable {
            case .error(let error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.description)
                        .frame(maxWidth: .infinity)
                        .font(.caption)

                    Button(action: {
                        viewModel.refreshRelatedLinks()
                    }, label: {
                        Label("Retry", systemImage: "arrow.clockwise")
                    })
                }

            case .fetching, .waiting:
                ProgressView()

            case .fetched(let relatedLinks):
                ForEach(relatedLinks, id: \.urlString) {
                    RelatedLinkView(relatedLink: $0)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                }
            }
        }
        .onAppear {
            viewModel.fetchRelatedLinks()
        }
    }
}
