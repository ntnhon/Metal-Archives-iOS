//
//  ReleaseLineUpView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 11/10/2022.
//

import SwiftUI

struct ReleaseLineUpView: View {
    @EnvironmentObject private var preferences: Preferences
    @Binding var lineUpMode: ReleaseLineUpMode
    private let viewModel: ReleaseLineUpViewModel
    private let onSelectArtist: (String) -> Void

    init(lineUpMode: Binding<ReleaseLineUpMode>,
         release: Release,
         onSelectArtist: @escaping (String) -> Void)
    {
        _lineUpMode = lineUpMode
        viewModel = .init(release: release)
        self.onSelectArtist = onSelectArtist
    }

    var body: some View {
        if viewModel.applicableModes.isEmpty {
            Text("None")
                .font(.callout.italic())
        } else {
            LazyVStack(spacing: 10) {
                HStack {
                    modePicker
                    Spacer()
                }

                ForEach(viewModel.lineUps(for: lineUpMode), id: \.hashValue) { lineUp in
                    if let title = lineUp.title {
                        Text(title)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .font(.body.italic())
                    }
                    ForEach(lineUp.members, id: \.hashValue) { band in
                        BandInReleaseView(band: band, onSelectArtist: onSelectArtist)
                    }

                    Divider()
                }
            }
        }
    }

    private var modePicker: some View {
        Menu(content: {
            ForEach(viewModel.applicableModes, id: \.self) { mode in
                Button(action: {
                    lineUpMode = mode
                }, label: {
                    HStack {
                        Text(viewModel.title(for: mode))
                        if mode == lineUpMode {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                })
            }
        }, label: {
            Label(viewModel.title(for: lineUpMode),
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

private struct BandInReleaseView: View {
    let band: BandInRelease
    let onSelectArtist: (String) -> Void

    var body: some View {
        VStack {
            if let name = band.name {
                Text(name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
            }

            ForEach(band.members) { member in
                ArtistInReleaseView(artist: member)
                    .onTapGesture {
                        onSelectArtist(member.thumbnailInfo.urlString)
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ArtistInReleaseView: View {
    @EnvironmentObject private var preferences: Preferences
    let artist: ArtistInRelease

    var body: some View {
        HStack(alignment: .top) {
            ThumbnailView(thumbnailInfo: artist.thumbnailInfo,
                          photoDescription: artist.name)
                .font(.largeTitle)
                .foregroundColor(preferences.theme.secondaryColor)
                .frame(width: 64)

            VStack(alignment: .leading, spacing: 8) {
                Text(artist.name)
                    .font(.title3.weight(.bold))
                    .foregroundColor(preferences.theme.primaryColor)
                if let additionalDetail = artist.additionalDetail {
                    Text(additionalDetail)
                }
                Text(artist.instruments)
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}
