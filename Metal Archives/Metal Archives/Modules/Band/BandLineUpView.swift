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
    private let viewModel: BandLineUpViewModel!

    init(band: Band) {
        viewModel = .init(band: band)
        _lineUpType = State(initialValue: viewModel.defaultLineUpType)
    }

    var body: some View {
        Group {
            HStack {
                MemberLineUpTypePicker(viewModel: viewModel,
                                       lineUpType: $lineUpType)
                Spacer()
            }

            ForEach(viewModel.artists(for: lineUpType), id: \.name) {
                ArtistInBandView(artist: $0)
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
        Picker(selection: $lineUpType,
               label: lineUpTypeView) {
            ForEach(viewModel.lineUpDetails, id: \.type) { lineUpDetail in
                Text(viewModel.title(for: lineUpDetail.type))
                    .tag(lineUpDetail.type)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }

    private var lineUpTypeView: some View {
        Text(viewModel.title(for: lineUpType) + " ≡ ")
            .padding(6)
            .background(preferences.theme.primaryColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct BandLineUpView_Previews: PreviewProvider {
    static var previews: some View {
        BandLineUpView(band: .death)
    }
}

private final class BandLineUpViewModel {
    let band: Band
    let lineUpDetails: [MemberLineUpDetail]
    let defaultLineUpType: MemberLineUpType

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

        defaultLineUpType = band.isLastKnownLineUp ? .lastKnown : .current

        self.lineUpDetails = lineUpDetails
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
