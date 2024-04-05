//
//  UserViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import Factory
import SwiftUI

@MainActor
final class UserViewModel: ObservableObject {
    @Published private(set) var userFetchable: FetchableObject<User> = .fetching

    private let apiService = resolve(\DependenciesContainer.apiService)
    let urlString: String

    init(urlString: String) {
        self.urlString = urlString
    }

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
