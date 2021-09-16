//
//  BandLineUpView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/07/2021.
//

import SwiftUI

enum MemberLineUpType {
    case current, lastKnown, past, live
}

struct BandLineUpView: View {
    @State private var lineUpType: MemberLineUpType
    private let viewModel: BandLineUpViewModel!

    init(band: Band) {
        viewModel = .init(band: band)
        _lineUpType = State(initialValue: viewModel.defaultLineUpType)
    }

    var body: some View {
        Group {
            ForEach(viewModel.artists(for: lineUpType), id: \.name) {
                ArtistInBandView(artist: $0)
                    .padding(.vertical)
            }
        }
    }
}

struct BandLineUpView_Previews: PreviewProvider {
    static var previews: some View {
        BandLineUpView(band: .death)
    }
}

private final class BandLineUpViewModel {
    private let band: Band
    private let availableLineUpType: [MemberLineUpType]
    let defaultLineUpType: MemberLineUpType

    init(band: Band) {
        self.band = band
        var availableLineUpType = [MemberLineUpType]()
        if !band.currentLineUp.isEmpty {
            if band.isLastKnownLineUp {
                availableLineUpType.append(.lastKnown)
            } else {
                availableLineUpType.append(.current)
            }
        }
        if !band.pastMembers.isEmpty {
            availableLineUpType.append(.past)
        }
        if !band.liveMusicians.isEmpty {
            availableLineUpType.append(.live)
        }
        defaultLineUpType = availableLineUpType.first ?? .current
        self.availableLineUpType = availableLineUpType
    }

    func artists(for type: MemberLineUpType) -> [ArtistInBand] {
        switch type {
        case .current, .lastKnown: return band.currentLineUp
        case .past: return band.pastMembers
        case .live: return band.liveMusicians
        }
    }
}
