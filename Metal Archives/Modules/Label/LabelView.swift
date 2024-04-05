//
//  LabelView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/10/2022.
//

import SwiftUI

struct LabelView: View {
    @StateObject private var viewModel: LabelViewModel

    init(urlString: String) {
        _viewModel = .init(wrappedValue: .init(urlString: urlString))
    }

    var body: some View {
        ZStack {
            switch viewModel.labelFetchable {
            case .fetching:
                MALoadingIndicator()
            case let .fetched(label):
                LabelContentView(urlString: viewModel.urlString, label: label)
                    .environmentObject(viewModel)
            case let .error(error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.fetchLabel()
                    }
                }
            }
        }
        .task {
            await viewModel.fetchLabel()
        }
    }
}

private struct LabelContentView: View {
    @EnvironmentObject private var preferences: Preferences
    @EnvironmentObject private var viewModel: LabelViewModel
    @Environment(\.selectedPhoto) private var selectedPhoto
    @StateObject private var tabsDatasource: LabelTabsDatasource
    @StateObject private var currentRosterViewModel: LabelCurrentRosterViewModel
    @StateObject private var pastRosterViewModel: LabelPastRosterViewModel
    @StateObject private var releasesViewModel: LabelReleasesViewModel
    @State private var titleViewAlpha = 0.0
    @State private var logoScaleFactor: CGFloat = 1.0
    @State private var logoOpacity: Double = 1.0
    @State private var detail: Detail?
    private let logoViewHeight: CGFloat
    private let minLogoScaleFactor: CGFloat = 0.5
    private let maxLogoScaleFactor: CGFloat = 1.2
    let label: LabelDetail

    init(urlString: String, label: LabelDetail) {
        self.label = label
        _tabsDatasource = .init(wrappedValue: .init(label: label))
        _currentRosterViewModel = .init(wrappedValue: .init(urlString: urlString))
        _pastRosterViewModel = .init(wrappedValue: .init(urlString: urlString))
        _releasesViewModel = .init(wrappedValue: .init(urlString: urlString))
        logoViewHeight = label.logoUrlString != nil ? 300 : 0
    }

    var body: some View {
        ZStack(alignment: .top) {
            DetailView(detail: $detail)

            LabelLogoView(scaleFactor: $logoScaleFactor, opacity: $logoOpacity)
                .environmentObject(viewModel)
                .frame(height: logoViewHeight)
                .opacity(label.logoUrlString != nil ? 1 : 0)

            OffsetAwareScrollView(
                axes: .vertical,
                showsIndicator: true,
                onOffsetChanged: { point in
                    /// Calculate `titleViewAlpha`
                    let screenBounds = UIScreen.main.bounds
                    if point.y<0,
                        abs(point.y)>(min(screenBounds.width, screenBounds.height) / 4)
                    {
                        titleViewAlpha = (abs(point.y) + 300) / min(screenBounds.width, screenBounds.height)
                    } else {
                        titleViewAlpha = 0.0
                    }

                    /// Calculate `photoScaleFactor` & `photoOpacity`
                    if point.y < 0 {
                        var factor = min(1.0, 70 / abs(point.y))
                        factor = factor < minLogoScaleFactor ? minLogoScaleFactor : factor
                        logoScaleFactor = factor
                        logoOpacity = (factor - minLogoScaleFactor) / minLogoScaleFactor
                    } else {
                        var factor = max(1.0, point.y / 70)
                        factor = factor > maxLogoScaleFactor ? maxLogoScaleFactor : factor
                        logoScaleFactor = factor
                    }
                },
                content: {
                    VStack(alignment: .leading, spacing: 0) {
                        Color.gray
                            .opacity(0.001)
                            .frame(height: logoViewHeight)
                            .onTapGesture {
                                if let logoImage = viewModel.logo {
                                    selectedPhoto.wrappedValue = .init(image: logoImage,
                                                                       description: label.name)
                                }
                            }

                        LabelInfoView(label: label) { url in
                            detail = .label(url)
                        }

                        HorizontalTabs(datasource: tabsDatasource)
                            .padding(.vertical)
                            .background(Color(.systemBackground))

                        let screenBounds = UIScreen.main.bounds
                        let maxSize = max(screenBounds.height, screenBounds.width)
                        let bottomSectionMinHeight = maxSize - logoViewHeight // 🪄✨
                        ZStack {
                            switch tabsDatasource.selectedTab {
                            case .subLabels:
                                subLabelList
                                    .padding(.horizontal)

                            case .currentRoster, .lastKnownRoster:
                                LabelCurrentRosterView(viewModel: currentRosterViewModel) { url in
                                    detail = .band(url)
                                }
                                .padding([.horizontal, .bottom])

                            case .pastRoster:
                                LabelPastRosterView(viewModel: pastRosterViewModel) { url in
                                    detail = .band(url)
                                }
                                .padding([.horizontal, .bottom])

                            case .releases:
                                LabelReleasesView(viewModel: releasesViewModel,
                                                  onSelectBand: { url in detail = .band(url) },
                                                  onSelectRelease: { url in detail = .release(url) })
                                    .padding([.horizontal, .bottom])

                            case .additionalNotes:
                                if let notes = label.additionalNotes {
                                    HighlightableText(text: notes,
                                                      highlights: ["Description", "Trivia"],
                                                      highlightFontWeight: .bold,
                                                      highlightColor: .primary)
                                        .padding([.horizontal, .bottom])
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                            case .links:
                                LabelRelatedLinksView(viewModel: viewModel)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            }
                        }
                        .frame(minHeight: bottomSectionMinHeight, alignment: .top)
                        .background(Color(.systemBackground))
                    }
                }
            )
        }
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Group {
                switch viewModel.logoFetchable {
                case let .fetched(image):
                    if let image {
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
            Text(label.name)
                .font(.title2)
                .fontWeight(.bold)
                .textSelection(.enabled)
                .minimumScaleFactor(0.5)
                .opacity(titleViewAlpha)
        }
    }

    private var subLabelList: some View {
        LazyVStack {
            ForEach(label.subLabels, id: \.hashValue) { subLabel in
                HStack {
                    if let thumbnailInfo = subLabel.thumbnailInfo {
                        ThumbnailView(thumbnailInfo: thumbnailInfo, photoDescription: subLabel.name)
                            .font(.largeTitle)
                            .foregroundColor(preferences.theme.secondaryColor)
                            .frame(width: 64, height: 64)
                    }
                    Text(subLabel.name)
                        .fontWeight(.medium)
                        .foregroundColor(preferences.theme.primaryColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    if let urlString = subLabel.thumbnailInfo?.urlString {
                        detail = .label(urlString)
                    }
                }

                Divider()
            }
        }
    }
}
