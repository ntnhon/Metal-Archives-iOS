//
//  DiscographyView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/07/2021.
//

import SwiftUI

struct DiscographyView: View {
    @EnvironmentObject private var preferences: Preferences
    @StateObject private var viewModel: DiscographyViewModel
    @State private var selectedMode: DiscographyMode = .complete
    @State private var releaseYearOrder: Order
    @State private var showingRelease = false
    @State private var selectedRelease: ReleaseInBand?

    init(discography: Discography, releaseYearOrder: Order) {
        _viewModel = StateObject(wrappedValue: .init(discography: discography))
        _releaseYearOrder = State(initialValue: releaseYearOrder)
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
            ForEach(viewModel.releases(for: selectedMode,
                                       order: releaseYearOrder),
                    id: \.thumbnailInfo.id) { release in
                NavigationLink(
                    isActive: $showingRelease,
                    destination: {
                        ReleaseView(releaseUrlString: release.thumbnailInfo.urlString)
                    },
                    label: {
                        ReleaseInBandView(release: release)
                            .padding(.vertical, 8)
                            .contextMenu {
                                Button(action: {
                                    showingRelease.toggle()
                                }, label: {
                                    Label("View release detail", systemImage: "opticaldisc")
                                })

                                Button(action: {
                                    selectedRelease = release
                                }, label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                })
                            }
                    })
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: showingShareSheet) {
            if let selectedRelease = selectedRelease,
               let url = URL(string: selectedRelease.thumbnailInfo.urlString) {
                ActivityView(items: [url])
            } else {
                ActivityView(items: [selectedRelease?.thumbnailInfo.urlString ?? ""])
            }
        }
    }

    private var options: some View {
        HStack {
            DiscographyModePicker(viewModel: viewModel,
                                  selectedMode: $selectedMode)
            Spacer()
            OrderView(order: $releaseYearOrder, title: "Release year")
        }
    }
}

struct DiscographyView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            ScrollView {
                VStack {
                    DiscographyView(discography: .death, releaseYearOrder: .ascending)
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
    @Binding var selectedMode: DiscographyMode

    var body: some View {
        Menu(content: {
            ForEach(viewModel.modes, id: \.self) { mode in
                Button(action: {
                    selectedMode = mode
                }, label: {
                    HStack {
                        Text(viewModel.title(for: mode))
                        if mode == selectedMode {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                })
            }
        }, label: {
            Label(viewModel.title(for: selectedMode),
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
