//
//  TopAlbumsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Foundation

final class TopAlbumsViewModel: ObservableObject {
    let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
}
