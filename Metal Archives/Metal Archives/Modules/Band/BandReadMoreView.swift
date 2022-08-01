//
//  BandReadMoreView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/07/2021.
//

import Combine
import SwiftUI

struct BandReadMoreView: View {
    @EnvironmentObject private var preferences: Preferences
    @EnvironmentObject private var viewModel: BandViewModel
    @State private var showingSheet = false

    var body: some View {
        Group {
            switch viewModel.readMoreFetchable {
            case .error(let error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.userFacingMessage)
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
                    Text(content)
                        .font(.callout)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(6)
                        .padding()
                        .onTapGesture {
                            showingSheet.toggle()
                        }
                } else {
                    EmptyView()
                }
            }
        }
        .sheet(isPresented: $showingSheet) {
            if case .fetched(let readMore) = viewModel.readMoreFetchable {
                NavigationView {
                    ScrollView {
                        Text(readMore.content ?? "")
                            .padding()
                    }
                    .navigationTitle(viewModel.band?.name ?? "")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showingSheet.toggle()
                            }, label: {
                                Image(systemName: "xmark")
                            })
                        }
                    }
                }
                .tint(preferences.theme.primaryColor)
                .preferredColorScheme(.dark)
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
