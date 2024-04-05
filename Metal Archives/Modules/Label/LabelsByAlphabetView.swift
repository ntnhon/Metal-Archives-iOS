//
//  LabelsByAlphabetView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import SwiftUI

struct LabelsByAlphabetView: View {
    @StateObject private var viewModel: LabelsByAlphabetViewModel
    @Environment(\.openURL) private var openURL

    init(letter: Letter) {
        _viewModel = .init(wrappedValue: .init(letter: letter))
    }

    var body: some View {
        ZStack {
            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.getMoreLabels(force: true)
                    }
                }
            } else if viewModel.isLoading && viewModel.labels.isEmpty {
                MALoadingIndicator()
            } else if viewModel.labels.isEmpty {
                Text("No labels found")
                    .font(.callout.italic())
            } else {
                labelList
            }
        }
        .task {
            await viewModel.getMoreLabels(force: false)
        }
    }

    @ViewBuilder
    private var labelList: some View {
        List {
            ForEach(viewModel.labels, id: \.label) { label in
                NavigationLink(destination: {
                    if let urlString = label.label.thumbnailInfo?.urlString {
                        LabelView(urlString: urlString)
                    } else {
                        EmptyView()
                    }
                }, label: {
                    LabelByAlphabetView(label: label)
                })
                .contextMenu {
                    if let website = label.website {
                        Button(action: {
                            openURL(urlString: website)
                        }, label: {
                            Label("Visit website", systemImage: "link.circle")
                        })
                    }
                }
                .task {
                    if label == viewModel.labels.last {
                        await viewModel.getMoreLabels(force: true)
                    }
                }

                if label == viewModel.labels.last, viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("\(viewModel.manager.total) labels by \"\(viewModel.letter.description)\"")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Menu(content: {
                Button(action: {
                    viewModel.sortOption = .name(.ascending)
                }, label: {
                    view(for: .name(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .name(.descending)
                }, label: {
                    view(for: .name(.descending))
                })

                Button(action: {
                    viewModel.sortOption = .specialisation(.ascending)
                }, label: {
                    view(for: .specialisation(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .specialisation(.descending)
                }, label: {
                    view(for: .specialisation(.descending))
                })

                Button(action: {
                    viewModel.sortOption = .status(.ascending)
                }, label: {
                    view(for: .status(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .status(.descending)
                }, label: {
                    view(for: .status(.descending))
                })

                Button(action: {
                    viewModel.sortOption = .country(.ascending)
                }, label: {
                    view(for: .country(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .country(.descending)
                }, label: {
                    view(for: .country(.descending))
                })

                Button(action: {
                    viewModel.sortOption = .onlineShopping(.ascending)
                }, label: {
                    view(for: .onlineShopping(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .onlineShopping(.descending)
                }, label: {
                    view(for: .onlineShopping(.descending))
                })
            }, label: {
                Text(viewModel.sortOption.title)
            })
            .transaction { transaction in
                transaction.animation = nil
            }
            .opacity(viewModel.labels.isEmpty ? 0 : 1)
            .disabled(viewModel.labels.isEmpty)
        }
    }

    @ViewBuilder
    private func view(for option: LabelByAlphabetPageManager.SortOption) -> some View {
        if option == viewModel.sortOption {
            Label(option.title, systemImage: "checkmark")
        } else {
            Text(option.title)
        }
    }
}

private struct LabelByAlphabetView: View {
    @EnvironmentObject private var preferences: Preferences
    let label: LabelByAlphabet

    var body: some View {
        HStack(spacing: 8) {
            if let thumbnailInfo = label.label.thumbnailInfo {
                ThumbnailView(thumbnailInfo: thumbnailInfo,
                              photoDescription: label.label.name)
                    .font(.largeTitle)
                    .foregroundColor(preferences.theme.secondaryColor)
                    .frame(width: 64, height: 64)
            }

            VStack(alignment: .leading) {
                Text(label.label.name)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                if let country = label.country {
                    Text(country.nameAndFlag)
                        .foregroundColor(preferences.theme.secondaryColor) +
                        Text(" • ") +
                        Text(label.status.rawValue)
                        .foregroundColor(label.status.color)
                } else {
                    Text(label.status.rawValue)
                        .foregroundColor(label.status.color)
                }

                if let specialisation = label.specialisation {
                    Text(specialisation)
                        .font(.callout)
                }

                if let website = label.website {
                    Text(website)
                        .font(.caption)
                        .foregroundColor(preferences.theme.secondaryColor)
                }

                if label.onlineShopping {
                    Text("Online shopping")
                        .font(.caption)
                }

                Spacer()
            }

            Spacer()
        }
    }
}
