//
//  ReleaseView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import SwiftUI

struct ReleaseView: View {
    @StateObject private var viewModel: ReleaseViewModel

    init(releaseUrlString: String) {
        let viewModel = ReleaseViewModel(releaseUrlString: releaseUrlString)
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        Text("Release detail")
    }
}

struct ReleaseView_Previews: PreviewProvider {
    static var previews: some View {
        ReleaseView(releaseUrlString: "https://www.metal-archives.com/albums/Death/Human/606")
    }
}
