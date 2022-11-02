//
//  ArtistInfoView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 02/11/2022.
//

import SwiftUI

struct ArtistInfoView: View {
    let artist: Artist

    var body: some View {
        VStack(spacing: 0) {
            Text(artist.artistName)
                .font(.title)
                .fontWeight(.bold)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .background(GradientBackgroundView())

            VStack(alignment: .leading, spacing: 10) {
                ColorCustomizableLabel(title: artist.realFullName, systemImage: "person.text.rectangle.fill")

                if #available(iOS 16, *) {
                    ColorCustomizableLabel(title: artist.age, systemImage: "birthday.cake.fill")
                } else {
                    ColorCustomizableLabel(title: artist.age, systemImage: "calendar")
                }

                ColorCustomizableLabel(title: artist.origin, systemImage: "location.fill")

                ColorCustomizableLabel(title: artist.gender, systemImage: "person.fill.questionmark")

                if let rip = artist.rip {
                    ColorCustomizableLabel(title: rip, systemImage: "staroflife.fill")
                }

                if let causeOfDeath = artist.causeOfDeath {
                    if #available(iOS 16, *) {
                        ColorCustomizableLabel(title: causeOfDeath, systemImage: "microbe.fill")
                    } else {
                        ColorCustomizableLabel(title: causeOfDeath, systemImage: "allergens")
                    }
                }

                if let trivia = artist.trivia {
                    Text(trivia)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color(.systemBackground))
        }
    }
}
