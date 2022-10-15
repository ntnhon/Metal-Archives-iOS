//
//  LabelView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/10/2022.
//

import SwiftUI

struct LabelView: View {
    @StateObject private var viewModel: LabelViewModel

    init(apiService: APIServiceProtocol, urlString: String) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService,
                                               urlString: urlString))
    }

    var body: some View {
        Text("Label view")
    }
}
