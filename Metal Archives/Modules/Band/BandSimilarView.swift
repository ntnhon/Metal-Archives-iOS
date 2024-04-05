//
//  BandSimilarView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/07/2021.
//

import SwiftUI

struct BandSimilarView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var showingDetail = false
    @State private var showingShareSheet = false
    let bandSimilar: BandSimilar

    var body: some View {
        let urlString = bandSimilar.thumbnailInfo.urlString
        NavigationLink(
            isActive: $showingDetail,
            destination: {
                BandView(bandUrlString: urlString)
            },
            label: {
                HStack {
                    ThumbnailView(thumbnailInfo: bandSimilar.thumbnailInfo,
                                  photoDescription: bandSimilar.name)
                        .font(.largeTitle)
                        .foregroundColor(preferences.theme.secondaryColor)
                        .frame(width: 64, height: 64)

                    VStack(alignment: .leading) {
                        Text(bandSimilar.name)
                            .fontWeight(.bold)
                            .foregroundColor(preferences.theme.primaryColor)
                        Text(bandSimilar.country.nameAndFlag)
                            .font(.callout)
                            .foregroundColor(.secondary)
                        Text(bandSimilar.genre)
                            .font(.callout)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Text("\(bandSimilar.score)")
                        .fontWeight(.medium)
                        .foregroundColor(Color.byRating(bandSimilar.score))
                }
            }
        )
        .buttonStyle(.plain)
        .contextMenu {
            Button(action: {
                showingDetail.toggle()
            }, label: {
                Label("View band detail", systemImage: "person.3")
            })

            Button(action: {
                UIPasteboard.general.string = bandSimilar.name
            }, label: {
                Label("Copy band name", systemImage: "doc.on.doc")
            })

            Button(action: {
                showingShareSheet.toggle()
            }, label: {
                Label("Share", systemImage: "square.and.arrow.up")
            })
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = URL(string: urlString) {
                ActivityView(items: [url])
            } else {
                ActivityView(items: [urlString])
            }
        }
    }
}

#Preview {
    let urlString = "https://www.metal-archives.com/bands/Possessed/914"
    // swiftlint:disable:next force_unwrapping
    let thumbnailInfo = ThumbnailInfo(urlString: urlString, type: .bandLogo)!
    let possessed = BandSimilar(thumbnailInfo: thumbnailInfo,
                                name: "Possessed",
                                country: .usa,
                                genre: "Death/Thrash Metal",
                                score: 291)
    return BandSimilarView(bandSimilar: possessed)
        .environmentObject(Preferences())
}
