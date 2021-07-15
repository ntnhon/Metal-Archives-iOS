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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "house.fill")
                    .foregroundColor(.secondary)
                Text(viewModel.band.country.nameAndFlag)
                Spacer()
            }

            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.secondary)
                Text(band.location)
                Spacer()
            }

            HStack {
                Image(systemName: "waveform.path")
                    .foregroundColor(.secondary)
                Text(band.status.rawValue)
                    .foregroundColor(band.status.color)
                Spacer()
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(viewModel.yearOfCreationString)
                Spacer()
            }

            HStack {
                Image(systemName: "guitars.fill")
                    .foregroundColor(.secondary)
                Text(band.genre)
                    .fixedSize(horizontal: false,
                               vertical: true)
                Spacer()
            }

            HStack {
                Image(systemName: "music.quarternote.3")
                    .foregroundColor(.secondary)
                Text(band.lyricalTheme)
                    .fixedSize(horizontal: false,
                               vertical: true)
                Spacer()
            }

            reviewView

            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(.secondary)
                Button(action: {
                    if let labelUrlString = band.lastLabel.thumbnailInfo?.urlString {
                        onSelectLabel(labelUrlString)
                    }
                },
                label: {
                    Text(band.lastLabel.name)
                        .fontWeight(band.lastLabel.thumbnailInfo == nil ? .regular : .bold)
                        .foregroundColor(band.lastLabel.thumbnailInfo == nil ? .primary : preferences.theme.primaryColor)
                })
                Spacer()
            }

            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.secondary)
                Text(DateFormatter.default.string(from: band.modificationInfo.modifiedOnDate!))
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .font(.callout)
    }

    private var reviewView: some View {
        HStack {
            Image(systemName: "quote.bubble.fill")
                .foregroundColor(.secondary)
            if viewModel.reviewCount == 0 {
                Text("No review yet")
            } else {
                Text("\(viewModel.reviewCount)")
                    .fontWeight(.bold)
                    + Text(" review\(viewModel.reviewCount > 0 ? "s" : "") • ")
                    + Text("\(viewModel.averageRating)%")
                    .fontWeight(.bold)
                    .foregroundColor(Color.byRating(viewModel.averageRating))
                    + Text(" on average" + (viewModel.platiniumCount == 0 ? "" : " • "))
                    + Text(viewModel.platiniumCount == 0 ? "" : "\(viewModel.platiniumCount)🏅")
                    .fontWeight(.bold)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
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
        if ratings.isEmpty {
            self.averageRating = 0
        } else {
            self.averageRating = ratings.reduce(0, +) / ratings.count
        }
        self.platiniumCount = discography.releases.filter { $0.isPlatinium }.count
    }
}
