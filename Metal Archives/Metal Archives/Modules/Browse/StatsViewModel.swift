//
//  StatsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import SwiftUI

final class StatsViewModel: ObservableObject {
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
}
