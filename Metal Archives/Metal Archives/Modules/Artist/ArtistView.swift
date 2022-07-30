//
//  ArtistView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/10/2021.
//

import SwiftUI

struct ArtistView: View {
    @StateObject private var viewModel: ArtistViewModel

    init(artistUrlString: String) {
        let viewModel = ArtistViewModel(artistUrlString: artistUrlString)
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        Text("Artist view")
    }
}

struct ArtistView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistView(artistUrlString: "https://www.metal-archives.com/artists/Randy_Blythe/23498")
    }
}
