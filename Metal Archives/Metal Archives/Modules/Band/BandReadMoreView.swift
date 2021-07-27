//
//  BandReadMoreView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/07/2021.
//

import SwiftUI

struct BandReadMoreView: View {
    @EnvironmentObject private var viewModel: BandViewModel

    var body: some View {
        Group {
            switch viewModel.readMoreFetchable {
            case .error(let error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.description)
                        .frame(maxWidth: .infinity)
                        .font(.caption)

                    Button(action: {
                        viewModel.refreshReadMore()
                    }, label: {
                        Label("Retry", systemImage: "arrow.clockwise")
                    })
                }

            case .fetching, .waiting:
                ProgressView()

            case .fetched(let readMore):
                if let content = readMore.content {
                    ExpandableText(content: content)
                        .padding()
                } else {
                    EmptyView()
                }
            }
        }
        .onAppear {
            viewModel.fetchReadMore()
        }
    }
}

struct BandReadMoreView_Previews: PreviewProvider {
    static var previews: some View {
        BandReadMoreView()
    }
}
