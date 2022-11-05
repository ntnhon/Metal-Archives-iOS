//
//  LabelView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/10/2022.
//

import SwiftUI

struct LabelView: View {
    @StateObject private var viewModel: LabelViewModel

    init(apiService: APIServiceProtocol, urlString: String) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService,
                                               urlString: urlString))
    }

    var body: some View {
        ZStack {
            switch viewModel.labelFetchable {
            case .fetching:
                HornCircularLoader()
            case .fetched(let label):
                LabelContentView(label: label)
                    .environmentObject(viewModel)
            case .error(let error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        Task {
                            await viewModel.fetchLabel()
                        }
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
    @EnvironmentObject private var viewModel: LabelViewModel
    @Environment(\.selectedPhoto) private var selectedPhoto
    @StateObject private var tabsDatasource: LabelTabsDatasource
    @State private var titleViewAlpha = 0.0
    @State private var logoScaleFactor: CGFloat = 1.0
    @State private var logoOpacity: Double = 1.0
    @State private var selectedLabelUrl: String?
    @State private var selectedBandUrl: String?
    @State private var selectedReleaseUrl: String?
    private let logoViewHeight: CGFloat
    private let minLogoScaleFactor: CGFloat = 0.5
    private let maxLogoScaleFactor: CGFloat = 1.2
    let label: LabelDetail

    init(label: LabelDetail) {
        self.label = label
        self._tabsDatasource = .init(wrappedValue: .init(label: label))
        self.logoViewHeight = label.logoUrlString != nil ? 300 : 0
    }

    var body: some View {
        let isShowingLabelDetail = makeIsShowingLabelDetailBinding()
        let isShowingBandDetail = makeIsShowingBandDetailBinding()
        let isShowingReleaseDetail = makeIsShowingReleaseDetailBinding()

        ZStack(alignment: .top) {
            NavigationLink(
                isActive: isShowingLabelDetail,
                destination: {
                    if let selectedLabelUrl {
                        LabelView(apiService: viewModel.apiService, urlString: selectedLabelUrl)
                    } else {
                        EmptyView()
                    }},
                label: { EmptyView() })

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
                    if point.y < 0,
                       abs(point.y) > (min(screenBounds.width, screenBounds.height) / 4) {
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
                            selectedLabelUrl = url
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
                                Text("Sub labels")
                            case .currentRoster:
                                Text("Current")
                            case .lastKnownRoster:
                                Text("Last known")
                            case .pastRoster:
                                Text("Past")
                            case .releases:
                                Text("Releases")
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
                                Text("Links")
                            }
                        }
                        .frame(minHeight: bottomSectionMinHeight, alignment: .top)
                        .background(Color(.systemBackground))
                    }
                })
        }
        .toolbar { toolbarContent }
    }

    private func makeIsShowingLabelDetailBinding() -> Binding<Bool> {
        .init(get: {
            selectedLabelUrl != nil
        }, set: { newValue in
            if !newValue {
                selectedLabelUrl = nil
            }
        })
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

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Group {
                switch viewModel.logoFetchable {
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
            Text(label.name)
                .font(.title2)
                .fontWeight(.bold)
                .textSelection(.enabled)
                .minimumScaleFactor(0.5)
                .opacity(titleViewAlpha)
        }
    }
}
