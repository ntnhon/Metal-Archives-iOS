//
//  Top100BandsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/06/2021.
//

import SwiftUI

private enum Top100BandsType: String, CaseIterable {
    case numOfReleases = "N° releases"
    case numOfFullLengths = "N° full-lengths"
    case numOfReviews = "N° reviews"
}

struct Top100BandsView: View {
    @State private var type: Top100BandsType = .numOfReleases

    var body: some View {
        ScrollView {
            LazyVStack {}
        }
        .toolbar {
            Picker("", selection: $type) {
                ForEach(Top100BandsType.allCases, id: \.self) { type in
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

struct Top100BandsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Top100BandsView()
        }
    }
}
