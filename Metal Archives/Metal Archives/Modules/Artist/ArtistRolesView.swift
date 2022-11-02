//
//  ArtistRolesView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 02/11/2022.
//

import SwiftUI

struct ArtistRolesView: View {
    let roles: [RoleInBand]

    var body: some View {
        LazyVStack {
            ForEach(roles, id: \.hashValue) {
                RoleInBandView(role: $0)
                Divider()
            }
        }
    }
}

private struct RoleInBandView: View {
    @EnvironmentObject private var preferences: Preferences
    let role: RoleInBand

    var body: some View {
        VStack {
            HStack {
                if let thumbnailInfo = role.band.thumbnailInfo {
                    ThumbnailView(thumbnailInfo: thumbnailInfo, photoDescription: role.band.name)
                        .font(.largeTitle)
                        .foregroundColor(preferences.theme.secondaryColor)
                        .frame(width: 64, height: 64)
                }

                VStack(alignment: .leading) {
                    Text(role.band.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor)

                    Text(role.description)
                        .fontWeight(.medium)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(role.roleInReleases, id: \.hashValue) {
                RoleInReleaseView(role: $0)
                    .padding(.leading)
            }
        }
    }
}

private struct RoleInReleaseView: View {
    @EnvironmentObject private var preferences: Preferences
    let role: RoleInRelease

    var body: some View {
        HStack {
            Text(role.year)
                .fontWeight(.medium)

            ThumbnailView(thumbnailInfo: role.release.thumbnailInfo,
                          photoDescription: role.release.title)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(role.release.title)
                    .foregroundColor(preferences.theme.secondaryColor)
                    .fontWeight(.medium)

                if let releaseAdditionalInfo = role.releaseAdditionalInfo {
                    Text("(\(releaseAdditionalInfo))")
                        .foregroundColor(.secondary)
                        .font(.callout.italic())
                }

                Text(role.description)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
