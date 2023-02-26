//
//  BandLineUpView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/07/2021.
//

import SwiftUI

private enum MemberLineUpType: CustomStringConvertible {
    case complete, current, lastKnown, past, live

    var description: String {
        switch self {
        case .complete: return "Complete lineup"
        case .current: return "Current lineup"
        case .lastKnown: return "Last known lineup"
        case .past: return "Past members"
        case .live: return "Live musicians"
        }
    }
}

private struct MemberLineUpDetail {
    let type: MemberLineUpType
    let memberCount: Int
}

struct BandLineUpView: View {
    @State private var lineUpType: MemberLineUpType
    private let viewModel: BandLineUpViewModel
    private let apiService: APIServiceProtocol
    private let onSelectBand: (String) -> Void
    private let onSelectArtist: (String) -> Void

    init(apiService: APIServiceProtocol,
         band: Band,
         onSelectBand: @escaping (String) -> Void,
         onSelectArtist: @escaping (String) -> Void) {
        self.apiService = apiService
        viewModel = .init(band: band)
        _lineUpType = State(initialValue: viewModel.defaultLineUpType)
        self.onSelectBand = onSelectBand
        self.onSelectArtist = onSelectArtist
    }

    var body: some View {
        if viewModel.band.noMembers {
            Text("No members added")
                .font(.callout.italic())
        } else {
            memberList
        }
    }

    @ViewBuilder
    private var memberList: some View {
        LazyVStack {
            HStack {
                MemberLineUpTypePicker(viewModel: viewModel,
                                       lineUpType: $lineUpType)
                Spacer()
            }

            ForEach(viewModel.artists(for: lineUpType), id: \.name) { artist in
                ArtistInBandView(artist: artist,
                                 onSelectBand: onSelectBand,
                                 onSelectArtist: onSelectArtist)
                .padding(.vertical)
            }
        }
    }
}

private struct MemberLineUpTypePicker: View {
    @EnvironmentObject private var preferences: Preferences
    let viewModel: BandLineUpViewModel
    @Binding var lineUpType: MemberLineUpType

    var body: some View {
        Menu(content: {
            ForEach(viewModel.lineUpDetails, id: \.type) { lineUpDetail in
                Button(action: {
                    lineUpType = lineUpDetail.type
                }, label: {
                    HStack {
                        Text(viewModel.title(for: lineUpDetail.type))
                        if lineUpType == lineUpDetail.type {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                })
            }
        }, label: {
            Label(viewModel.title(for: lineUpType),
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

    private var lineUpTypeView: some View {
        Text(viewModel.title(for: lineUpType) + " ≡ ")
            .padding(6)
            .background(preferences.theme.primaryColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private final class BandLineUpViewModel {
    let band: Band
    let lineUpDetails: [MemberLineUpDetail]
    private(set) var defaultLineUpType: MemberLineUpType

    init(band: Band) {
        self.band = band
        var lineUpDetails = [MemberLineUpDetail]()
        if !band.currentLineUp.isEmpty {
            if band.isLastKnownLineUp {
                lineUpDetails.append(.init(type: .lastKnown, memberCount: band.currentLineUp.count))
            } else {
                lineUpDetails.append(.init(type: .current, memberCount: band.currentLineUp.count))
            }
        }
        if !band.pastMembers.isEmpty {
            lineUpDetails.append(.init(type: .past, memberCount: band.pastMembers.count))
        }
        if !band.liveMusicians.isEmpty {
            lineUpDetails.append(.init(type: .live, memberCount: band.liveMusicians.count))
        }

        if lineUpDetails.count > 1 {
            let completeMemberCount = band.currentLineUp.count + band.pastMembers.count + band.liveMusicians.count
            lineUpDetails.insert(.init(type: .complete, memberCount: completeMemberCount), at: 0)
        }

        self.defaultLineUpType = band.isLastKnownLineUp ? .lastKnown : .current
        self.lineUpDetails = lineUpDetails

        if artists(for: defaultLineUpType).isEmpty {
            self.defaultLineUpType = .past
        } else if self.artists(for: defaultLineUpType).isEmpty {
            self.defaultLineUpType = .live
        }
    }

    func artists(for type: MemberLineUpType) -> [ArtistInBand] {
        switch type {
        case .complete: return band.currentLineUp + band.pastMembers + band.liveMusicians
        case .current, .lastKnown: return band.currentLineUp
        case .past: return band.pastMembers
        case .live: return band.liveMusicians
        }
    }

    func title(for type: MemberLineUpType) -> String {
        guard let lineUpDetail = lineUpDetails.first(where: { $0.type == type }) else {
            return ""
        }
        return lineUpDetail.type.description + " (\(lineUpDetail.memberCount))"
    }
}
