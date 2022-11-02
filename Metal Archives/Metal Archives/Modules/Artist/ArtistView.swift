//
//  ArtistView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/10/2021.
//

import SwiftUI

struct ArtistView: View {
    @StateObject private var viewModel: ArtistViewModel

    init(apiService: APIServiceProtocol, urlString: String) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService,
                                               urlString: urlString))
    }

    var body: some View {
        ZStack {
            switch viewModel.artistFetchable {
            case .fetching:
                HornCircularLoader()
            case .fetched(let artist):
                ArtistContentView(artist: artist)
                    .environmentObject(viewModel)
            case .error(let error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        Task {
                            await viewModel.fetchArtist()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchArtist()
        }
    }
}

private struct ArtistContentView: View {
    @EnvironmentObject private var viewModel: ArtistViewModel
    @Environment(\.selectedPhoto) private var selectedPhoto
    @ObservedObject private var tabsDatasource: ArtistTabsDatasource
    @State private var titleViewAlpha = 0.0
    @State private var photoViewHeight: CGFloat
    @State private var photoScaleFactor: CGFloat = 1.0
    @State private var photoOpacity: Double = 1.0
    @State private var selectedBandUrl: String?
    @State private var selectedReleaseUrl: String?
    private let minPhotoScaleFactor: CGFloat = 0.5
    private let maxPhotoScaleFactor: CGFloat = 1.2
    let artist: Artist

    init(artist: Artist) {
        self.artist = artist
        self.tabsDatasource = .init(artist: artist)
        self._photoViewHeight = .init(initialValue: artist.hasPhoto ? 300 : 0)
    }

    var body: some View {
        let isShowingBandDetail = makeIsShowingBandDetailBinding()
        let isShowingReleaseDetail = makeIsShowingReleaseDetailBinding()

        ZStack(alignment: .top) {
            NavigationLink(
                isActive: isShowingBandDetail,
                destination: {
                    if let selectedBandUrl {
                        BandView(apiService: viewModel.apiService, bandUrlString: selectedBandUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            NavigationLink(
                isActive: isShowingReleaseDetail,
                destination: {
                    if let selectedReleaseUrl {
                        ReleaseView(apiService: viewModel.apiService,
                                    urlString: selectedReleaseUrl,
                                    parentRelease: nil)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

            ArtistPhotoView(scaleFactor: $photoScaleFactor, opacity: $photoOpacity)
                .environmentObject(viewModel)
                .frame(height: photoViewHeight)
                .opacity(artist.hasPhoto ? 1 : 0)

            OffsetAwareScrollView(
                axes: .vertical,
                showsIndicator: true,
                onOffsetChanged: { point in
                    /// Calculate `titleViewAlpha`
                    let screenBounds = UIScreen.main.bounds
                    if point.y < 0,
                       abs(point.y) > (min(screenBounds.width, screenBounds.height) / 4) {
                        titleViewAlpha = (abs(point.y) + 300) / min(screenBounds.width, screenBounds.height)
                    } else {
                        titleViewAlpha = 0.0
                    }

                    /// Calculate `photoScaleFactor` & `photoOpacity`
                    if point.y < 0 {
                        var factor = min(1.0, 70 / abs(point.y))
                        factor = factor < minPhotoScaleFactor ? minPhotoScaleFactor : factor
                        photoScaleFactor = factor
                        photoOpacity = (factor - minPhotoScaleFactor) / minPhotoScaleFactor
                    } else {
                        var factor = max(1.0, point.y / 70)
                        factor = factor > maxPhotoScaleFactor ? maxPhotoScaleFactor : factor
                        photoScaleFactor = factor
                    }
                },
                content: {
                    VStack(alignment: .leading, spacing: 0) {
                        Color.gray
                            .opacity(0.001)
                            .frame(height: photoViewHeight)
                            .onTapGesture {
                                if let photoImage = viewModel.photo {
                                    selectedPhoto.wrappedValue = .init(image: photoImage,
                                                                       description: artist.artistName)
                                }
                            }

                        ArtistInfoView(artist: artist)

                        HorizontalTabs(datasource: tabsDatasource)
                            .padding(.vertical)
                            .background(Color(.systemBackground))

                        let screenBounds = UIScreen.main.bounds
                        let maxSize = max(screenBounds.height, screenBounds.width)
                        let bottomSectionMinHeight = maxSize - photoViewHeight // 🪄✨
                        ZStack {
                            switch tabsDatasource.selectedTab {
                            case .activeBands:
                                artistRolesView(artist.activeRoles)

                            case .pastBands:
                                artistRolesView(artist.pastRoles)

                            case .live:
                                artistRolesView(artist.liveRoles)

                            case .guestSession:
                                artistRolesView(artist.guestSessionRoles)

                            case .miscStaff:
                                artistRolesView(artist.miscStaffRoles)

                            case .biography:
                                ArtistBiographyView(viewModel: viewModel, artist: artist)
                                    .padding([.horizontal, .bottom])
                                    .frame(maxWidth: .infinity, alignment: .leading)

                            case .links:
                                ArtistRelatedLinksView(viewModel: viewModel)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(minHeight: bottomSectionMinHeight, alignment: .top)
                        .background(Color(.systemBackground))
                    }
                })
        }
        .toolbar { toolbarContent }
    }

    private func makeIsShowingBandDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedBandUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedBandUrl = nil
            }
        })
    }

    private func makeIsShowingReleaseDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedReleaseUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedReleaseUrl = nil
            }
        })
    }

    private func artistRolesView(_ roles: [RoleInBand]) -> some View {
        ArtistRolesView(roles: roles,
                        onSelectBand: { url in selectedBandUrl = url },
                        onSelectRelease: { url in selectedReleaseUrl = url })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Group {
                switch viewModel.photoFetchable {
                case .fetched(let image):
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                            .padding(.vertical, 4)
                    }
                default:
                    EmptyView()
                }
            }
            .opacity(titleViewAlpha)
        }

        ToolbarItem(placement: .principal) {
            Text(artist.artistName)
                .font(.title2)
                .fontWeight(.bold)
                .textSelection(.enabled)
                .minimumScaleFactor(0.5)
                .opacity(titleViewAlpha)
        }
    }
}
