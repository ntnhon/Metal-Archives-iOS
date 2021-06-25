//
//  Top100AlbumsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/06/2021.
//

import SwiftUI

private enum Top100AlbumsType: String, CaseIterable {
    case numOfReviews = "N° reviews"
    case mostOwned = "Most owned"
    case mostWanted = "Most wanted"
}

struct Top100AlbumsView: View {
    @State private var type: Top100AlbumsType = .numOfReviews

    var body: some View {
        ScrollView {
            LazyVStack {}
        }
        .toolbar {
            Picker("", selection: $type) {
                ForEach(Top100AlbumsType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                        .tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .labelsHidden()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Top100AlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Top100AlbumsView()
        }
    }
}
