//
//  BandInfoView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/06/2021.
//

import SwiftUI

struct BandInfoView: View {
    @EnvironmentObject private var preferences: Preferences
    let viewModel: BandInfoViewModel
    var onSelectLabel: (String) -> Void
    var onSelectBand: (String) -> Void

    var body: some View {
        let band = viewModel.band
        let primaryColor = preferences.theme.primaryColor
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "house.fill")
                    .foregroundColor(primaryColor)
                Text(viewModel.band.country.nameAndFlag)
                Spacer()
            }

            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(primaryColor)
                Text(band.location)
                Spacer()
            }

            HStack {
                Image(systemName: "waveform.path")
                    .foregroundColor(primaryColor)
                Text(band.status.rawValue)
                    .foregroundColor(band.status.color)
                Spacer()
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(primaryColor)
                Text(viewModel.yearOfCreationString)
                Spacer()
            }

            HStack {
                Image(systemName: "guitars.fill")
                    .foregroundColor(primaryColor)
                Text(band.genre)
                Spacer()
            }

            HStack {
                Image(systemName: "music.quarternote.3")
                    .foregroundColor(primaryColor)
                Text(band.lyricalTheme)
                Spacer()
            }

            reviewView

            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(primaryColor)
                Button(action: {
                    if let labelUrlString = band.lastLabel.thumbnailInfo?.urlString {
                        onSelectLabel(labelUrlString)
                    }
                },
                label: {
                    Text(band.lastLabel.name)
                        .fontWeight(band.lastLabel.thumbnailInfo == nil ? .regular : .bold)
                        .foregroundColor(band.lastLabel.thumbnailInfo == nil ? .primary : primaryColor)
                })
                Spacer()
            }

            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(primaryColor)
                Text(DateFormatter.default.string(from: band.modificationInfo.modifiedOnDate!))
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var reviewView: some View {
        HStack {
            Image(systemName: "quote.bubble.fill")
                .foregroundColor(preferences.theme.primaryColor)
            if viewModel.reviewCount == 0 {
                Text("No review yet")
            } else {
                Text("\(viewModel.reviewCount)")
                    .fontWeight(.bold)
                    + Text(" review\(viewModel.reviewCount > 0 ? "s" : "") in total • ")
                    + Text("\(viewModel.averageRating)%")
                    .fontWeight(.bold)
                    .foregroundColor(Color.byRating(viewModel.averageRating))
                    + Text(" on average")
                    + Text(viewModel.platiniumCount == 0 ? "" : " • \(viewModel.platiniumCount) 🏅")
                    .fontWeight(.bold)
            }
        }
    }
}

struct BandInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandInfoView(viewModel: .init(band: .death, discography: .death),
                         onSelectLabel: { _ in },
                         onSelectBand: { _ in })
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}

final class BandInfoViewModel {
    let band: Band
    let yearOfCreationString: String
    let reviewCount: Int
    let averageRating: Int
    let platiniumCount: Int

    init(band: Band, discography: Discography) {
        self.band = band

        var yearOfCreationString = band.yearOfCreation
        if let year = Int(band.yearOfCreation) {
            let yearGap = Calendar.current.component(.year, from: .init()) - year
            switch yearGap {
            case 0: yearOfCreationString = "\(year)"
            case 1: yearOfCreationString = "\(year) (a year a go)"
            default: yearOfCreationString = "\(year) (\(yearGap) years ago)"
            }
        }
        self.yearOfCreationString = yearOfCreationString

        self.reviewCount = discography.releases.compactMap { $0.reviewCount }.reduce(0, +)
        let ratings = discography.releases.compactMap { $0.rating }
        self.averageRating = ratings.reduce(0, +) / ratings.count
        self.platiniumCount = discography.releases.filter { $0.isPlatinium }.count
    }
}
