//
//  ReleaseInfoView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 13/10/2022.
//

import SwiftUI

struct ReleaseInfoView: View {
    @EnvironmentObject private var preferences: Preferences
    let release: Release
    let onSelectBand: (String) -> Void
    let onSelectLabel: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text(release.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .textSelection(.enabled)

                Text(release.type.description)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.bottom)
            .background(GradientBackgroundView())

            VStack(alignment: .leading, spacing: 10) {
                if release.bands.count == 1, let band = release.bands.first {
                    singleBandView(band: band)
                } else {
                    bandsView
                }

                ColorCustomizableLabel(title: release.date, systemImage: "calendar")

                ColorCustomizableLabel(title: release.catalogId, systemImage: "books.vertical")

                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.secondary)
                    LabelLiteButton(label: release.label, onSelect: onSelectLabel)
                    Spacer()
                }

                ColorCustomizableLabel(title: release.format, systemImage: "opticaldisc")

                reviewView

                ColorCustomizableLabel(title: release.modificationInfo.summary, systemImage: "clock.fill")
            }
            .padding([.horizontal, .bottom])
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color(.systemBackground))

            Color(.systemGray6)
                .frame(height: 10)
        }
    }

    private func singleBandView(band: BandLite) -> some View {
        HStack {
            Image(systemName: "person.3.fill")
                .foregroundColor(.secondary)
            Button(action: {
                onSelectBand(band.thumbnailInfo.urlString)
            }, label: {
                Text(band.name)
                    .fontWeight(.bold)
                    .foregroundColor( preferences.theme.primaryColor)
            })
            Spacer()
        }
    }

    @ViewBuilder
    private var bandsView: some View {
        let texts = generateBandsText()
        HStack {
            Image(systemName: "person.3.fill")
                .foregroundColor(.secondary)
            texts.reduce(into: Text("")) { partialResult, text in
                // swiftlint:disable:next shorthand_operator
                partialResult = partialResult + text
            }
            .overlay(
                Menu(content: {
                    ForEach(release.bands, id: \.name) { band in
                        Button(action: {
                            onSelectBand(band.thumbnailInfo.urlString)
                        }, label: {
                            Text(band.name)
                        })
                    }
                }, label: {
                    Color.clear
                })
            )
            Spacer()
        }
    }

    private func generateBandsText() -> [Text] {
        var texts = [Text]()
        for (index, band) in release.bands.enumerated() {
            texts.append(
                Text(band.name)
                    .fontWeight(.medium)
                    .foregroundColor(preferences.theme.primaryColor))
            if index != release.bands.count - 1 {
                texts.append(Text(" / "))
            }
        }
        return texts
    }

    private var reviewView: some View {
        HStack {
            Image(systemName: "quote.bubble.fill")
                .foregroundColor(.secondary)
            if let reviewCount = release.reviewCount, reviewCount > 0 {
                let rating = release.rating ?? 0
                let isPlatinium = reviewCount >= 10 && rating >= 75
                Text("\(reviewCount)")
                    .fontWeight(.bold)
                    + Text(" review\(reviewCount > 1 ? "s" : "") • ")
                    + Text("\(rating)%")
                    .fontWeight(.bold)
                    .foregroundColor(Color.byRating(release.rating ?? 0))
                    + Text(" on average" + (!isPlatinium ? "" : " • "))
                    + Text(!isPlatinium ? "" : "🏅")
                    .fontWeight(.bold)
            } else {
                Text("No reviews yet")
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
