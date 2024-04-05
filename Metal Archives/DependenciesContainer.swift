//
//  DependenciesContainer.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 31/03/2024.
//

import Factory

final class DependenciesContainer: SharedContainer, AutoRegistering {
    static let shared = DependenciesContainer()
    let manager = ContainerManager()

    func autoRegister() {
        manager.defaultScope = .singleton
    }
}

extension DependenciesContainer {
    var apiService: Factory<APIServiceProtocol> {
        self { APIService() }
    }
}
