//
//  TopAlbumsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import SwiftUI

struct TopAlbumsView: View {
    @StateObject private var viewModel: TopAlbumsViewModel

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService))
    }

    var body: some View {
        Text("Top albums")
    }
}
