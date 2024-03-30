//
//  DiscographyView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/07/2021.
//

import SwiftUI

struct DiscographyView: View {
    @EnvironmentObject private var preferences: Preferences
    @ObservedObject private var viewModel: DiscographyViewModel
    @State private var showingRelease = false
    @State private var selectedRelease: ReleaseInBand?
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol,
         viewModel: DiscographyViewModel)
    {
        self.apiService = apiService
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        let showingShareSheet = Binding<Bool>(get: {
            selectedRelease != nil
        }, set: { newValue in
            if !newValue {
                selectedRelease = nil
            }
        })

        VStack {
            options
            Divider()
            LazyVStack {
                ForEach(viewModel.releases, id: \.thumbnailInfo.id) { release in
                    NavigationLink(
                        destination: {
                            ReleaseView(apiService: apiService,
                                        urlString: release.thumbnailInfo.urlString,
                                        parentRelease: nil)
                        },
                        label: {
                            let text = "\(release.title) (\(release.year)) (\(release.type.description))"
                            ReleaseInBandView(release: release)
                                .padding(.vertical, 8)
                                .contextMenu {
                                    Button(action: {
                                        UIPasteboard.general.string = text
                                    }, label: {
                                        Label("Copy release name", systemImage: "doc.on.doc")
                                    })

                                    Button(action: {
                                        selectedRelease = release
                                    }, label: {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    })
                                }
                        }
                    )
                    .buttonStyle(.plain)
                    Divider()
                }
            }
        }
        .sheet(isPresented: showingShareSheet) {
            if let selectedRelease,
               let url = URL(string: selectedRelease.thumbnailInfo.urlString)
            {
                ActivityView(items: [url])
            } else {
                ActivityView(items: [selectedRelease?.thumbnailInfo.urlString ?? ""])
            }
        }
    }

    private var options: some View {
        HStack {
            DiscographyModePicker(viewModel: viewModel)
            Spacer()
            OrderView(order: $viewModel.selectedOrder, title: "Release year")
        }
    }
}

struct DiscographyView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            ScrollView {
                VStack {
                    DiscographyView(apiService: APIService(),
                                    viewModel: .init(discography: .death,
                                                     discographyMode: .complete,
                                                     order: .ascending))
                }
            }
            .padding(.horizontal)
            .background(Color(.systemBackground))
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}

private struct DiscographyModePicker: View {
    @EnvironmentObject private var preferences: Preferences
    @ObservedObject var viewModel: DiscographyViewModel

    var body: some View {
        Menu(content: {
            ForEach(viewModel.modes, id: \.self) { mode in
                Button(action: {
                    viewModel.selectedMode = mode
                }, label: {
                    HStack {
                        Text(viewModel.title(for: mode))
                        if mode == viewModel.selectedMode {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                })
            }
        }, label: {
            Label(viewModel.title(for: viewModel.selectedMode),
                  systemImage: "line.3.horizontal")
                .padding(8)
                .background(preferences.theme.primaryColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        })
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}
