//
//  LyricView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 12/10/2022.
//

import SwiftUI

struct LyricView: View {
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: LyricViewModel
    @State private var copiedMessage: String?

    init(apiService: APIServiceProtocol, song: Song) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService,
                                               song: song))
    }

    var body: some View {
        NavigationView {
            Group {
                switch viewModel.lyricFetchable {
                case .fetching:
                    HornCircularLoader()
                case .fetched(let lyric):
                    ScrollView {
                        Text(lyric)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .textSelection(.enabled)
                    }
                case .error(let error):
                    VStack {
                        Text(error.userFacingMessage)
                        RetryButton {
                            Task {
                                await viewModel.fetchLyric()
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(viewModel.song.title)
            .toolbar { toolbarContent }
        }
        .tint(preferences.theme.primaryColor)
        .task { await viewModel.fetchLyric() }
        .alertToastCopyMessage($copiedMessage)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                if let lyric = viewModel.fetchedLyric {
                    UIPasteboard.general.string = "\(viewModel.song.title)\n\(lyric)"
                    copiedMessage = "Lyric copied"
                }
            }, label: {
                Label("Copy", systemImage: "doc.on.doc")
            })
            .opacity(viewModel.fetchedLyric != nil ? 1 : 0)
            .disabled(viewModel.fetchedLyric == nil)
        }
    }
}
