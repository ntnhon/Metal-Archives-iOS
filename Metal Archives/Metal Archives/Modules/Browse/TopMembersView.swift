//
//  TopMembersView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import SwiftUI

struct TopMembersView: View {
    @StateObject private var viewModel: TopMembersViewModel

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService))
    }

    var body: some View {
        Text("Top members view")
    }
}
