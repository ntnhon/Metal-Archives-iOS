//
//  Top100MembersView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/06/2021.
//

import SwiftUI

private enum Top100MembersType: String, CaseIterable {
    case submittedBands = "Submitted bands"
    case writtenReviews = "Written reviews"
    case submittedAlbums = "Submitted albums (since 2004)"
    case artistsAdded = "Artists added (since 2011)"
}

struct Top100MembersView: View {
    @State private var type: Top100MembersType = .submittedBands

    var body: some View {
        ScrollView {
            LazyVStack {}
        }
        .navigationBarTitle(type.rawValue, displayMode: .inline)
        .navigationBarItems(trailing:
                                Picker("Others", selection: $type) {
                                    ForEach(Top100MembersType.allCases, id: \.self) { type in
                                        Text(type.rawValue)
                                            .tag(type)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle()))
    }
}

struct Top100MembersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Top100MembersView()
        }
    }
}
