//
//  StatsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import SwiftUI

@available(iOS 16, *)
struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService))
    }

    var body: some View {
        Text("Stats")
    }
}
