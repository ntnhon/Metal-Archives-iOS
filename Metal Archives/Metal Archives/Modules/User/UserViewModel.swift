//
//  UserViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

final class UserViewModel: ObservableObject {
    @Published private(set) var userFetchable: FetchableObject<User> = .fetching

    let apiService: APIServiceProtocol
    let urlString: String

    init(apiService: APIServiceProtocol, urlString: String) {
        self.apiService = apiService
        self.urlString = urlString
    }

    @MainActor
    func fetchUser() async {
        if case .fetched = userFetchable { return }
        do {
            userFetchable = .fetching
            let user = try await apiService.request(forType: User.self, urlString: urlString)
            userFetchable = .fetched(user)
        } catch {
            userFetchable = .error(error)
        }
    }
}
