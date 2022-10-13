//
//  ReleaseInfoView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 13/10/2022.
//

import SwiftUI

struct ReleaseInfoView: View {
    let release: Release

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
            .background(
                LinearGradient(
                    gradient: .init(colors: [Color(.systemBackground),
                                             Color(.systemBackground.withAlphaComponent(0.9)),
                                             Color(.systemBackground.withAlphaComponent(0.8)),
                                             Color(.systemBackground.withAlphaComponent(0.7)),
                                             Color(.systemBackground.withAlphaComponent(0.6)),
                                             Color(.systemBackground.withAlphaComponent(0.5)),
                                             Color(.systemBackground.withAlphaComponent(0.4)),
                                             Color(.systemBackground.withAlphaComponent(0.3)),
                                             Color(.systemBackground.withAlphaComponent(0.2)),
                                             Color(.systemBackground.withAlphaComponent(0.1)),
                                             Color(.systemBackground.withAlphaComponent(0.05)),
                                             Color(.systemBackground.withAlphaComponent(0.025)),
                                             Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top)
            )

            VStack(alignment: .leading) {
                reviewView
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color(.systemBackground))
        }
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
