//
//  OtherVersionsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 11/10/2022.
//

import SwiftUI

struct OtherVersionsView: View {
    @ObservedObject var viewModel: ReleaseViewModel
    @Environment(\.toastMessage) private var toastMessage
    var onSelectRelease: (String) -> Void

    var body: some View {
        ZStack {
            switch viewModel.otherVersionsFetchable {
            case .fetching:
                ProgressView()

            case let .fetched(otherVersions):
                if otherVersions.count == 1 {
                    Text("No other versions")
                        .font(.callout.italic())
                        .padding(.horizontal)
                } else {
                    otherVersionList(otherVersions)
                }

            case let .error(error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.fetchOtherVersions()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .task {
            await viewModel.fetchOtherVersions()
        }
    }

    private func otherVersionList(_ otherVersions: [ReleaseOtherVersion]) -> some View {
        LazyVStack(alignment: .leading) {
            ForEach(otherVersions, id: \.urlString) { otherVersion in
                OtherVersionView(otherVersion: otherVersion)
                    .onTapGesture {
                        if otherVersion.isCurrentVersion {
                            toastMessage.wrappedValue = "You're viewing this version"
                        } else {
                            onSelectRelease(otherVersion.urlString)
                        }
                    }

                Divider()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct OtherVersionView: View {
    @EnvironmentObject private var preferences: Preferences
    let otherVersion: ReleaseOtherVersion

    var body: some View {
        HStack {
            if let thumbnailInfo = otherVersion.thumbnailInfo {
                ThumbnailView(thumbnailInfo: thumbnailInfo,
                              photoDescription: otherVersion.description)
                    .font(.largeTitle)
                    .foregroundColor(preferences.theme.secondaryColor)
                    .frame(width: 64)
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(otherVersion.date)
                        .foregroundColor(preferences.theme.primaryColor)
                        .fontWeight(.bold)

                    Spacer()

                    if otherVersion.isUnofficial {
                        Text("Unofficial")
                            .foregroundColor(.red)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }

                if let additionalDetail = otherVersion.additionalDetail,
                   !additionalDetail.isEmpty,
                   !otherVersion.isUnofficial,
                   !additionalDetail.contains("Unofficial")
                {
                    Text(additionalDetail)
                }

                Text(otherVersion.labelName)

                Text([otherVersion.catalogId, otherVersion.format].filter { !$0.isEmpty }.joined(separator: " • "))

                Text(otherVersion.description)
                    .font(.callout)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .padding(.horizontal)
        .background(otherVersion.isCurrentVersion ? Color.red.opacity(0.2) : Color.clear)
    }
}
