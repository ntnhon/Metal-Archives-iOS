//
//  LabelViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/10/2022.
//

import SwiftUI

final class LabelViewModel: ObservableObject {
    private let apiService: APIServiceProtocol
    private let urlString: String

    init(apiService: APIServiceProtocol, urlString: String) {
        self.apiService = apiService
        self.urlString = urlString
    }
}
