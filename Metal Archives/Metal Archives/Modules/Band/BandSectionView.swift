//
//  BandSectionView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/07/2021.
//

import SwiftUI

enum BandSection: Int, CaseIterable {
    case discography
    case members
    case reviews
    case similarArtists
    case relatedLinks

    var description: String {
        switch self {
        case .discography: return "Discography"
        case .members: return "Members"
        case .reviews: return "Reviews"
        case .similarArtists: return "Similar Artists"
        case .relatedLinks: return "Related Links"
        }
    }
}

struct BandSectionView: View {
    @EnvironmentObject private var preferences: Preferences
    @Binding var selectedSection: BandSection

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollViewReader in
                HStack(spacing: 0) {
                    ForEach(BandSection.allCases, id: \.self) {
                        sectionView(for: $0,
                                    proxy: scrollViewReader)
                    }
                }
                .padding(.leading)
            }
        }
    }

    private func sectionView(for section: BandSection,
                             proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 0) {
            Text(section.description)
                .fontWeight(.medium)
                .foregroundColor(section == selectedSection ? preferences.theme.primaryColor : .secondary)
            Color(.separator)
                .frame(width: 1, height: 16)
                .padding(.horizontal)
        }
        .id(section.rawValue)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                selectedSection = section
                proxy.scrollTo(section.rawValue, anchor: .center)
            }
        }
    }
}

private struct BandSectionViewPreview: View {
    @State private var selectedSection: BandSection = .discography

    var body: some View {
        BandSectionView(selectedSection: $selectedSection)
    }
}

struct BandSectionView_Previews: PreviewProvider {
    static var previews: some View {
        BandSectionViewPreview()
            .environmentObject(Preferences())
    }
}
