//
//  LabelViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/10/2022.
//

import SwiftUI

final class LabelViewModel: ObservableObject {
    deinit { print("\(Self.self) of \(urlString) is deallocated") }

    private let apiService: APIServiceProtocol
    private let urlString: String

    init(apiService: APIServiceProtocol, urlString: String) {
        self.apiService = apiService
        self.urlString = urlString
    }
}
