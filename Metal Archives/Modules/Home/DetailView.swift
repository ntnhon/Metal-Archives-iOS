//
//  DetailView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/12/2022.
//

import SwiftUI

enum Detail: Hashable {
    case band(String)
    case artist(String)
    case release(String)
    case label(String)
    case review(String)
    case user(String)
}

struct DetailView: View {
    let detail: Detail
    @Binding var path: NavigationPath

    var body: some View {
        switch detail {
        case let .band(urlString):
            BandView(bandUrlString: urlString, path: $path)
        case let .artist(urlString):
            ArtistView(urlString: urlString, path: $path)
        case let .release(urlString):
            ReleaseView(urlString: urlString, parentRelease: nil, path: $path)
        case let .label(urlString):
            LabelView(urlString: urlString, path: $path)
        case let .review(urlString):
            ReviewView(urlString: urlString, path: $path)
        case let .user(urlString):
            UserView(urlString: urlString, path: $path)
        }
    }
}
