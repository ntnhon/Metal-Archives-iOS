//
//  ReleaseViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import Combine

final class ReleaseViewModel: ObservableObject {
    private(set) var release: Release?
    private var cancellables = Set<AnyCancellable>()
    private let releaseUrlString: String

    deinit {
        print("\(Self.self) of \(releaseUrlString) is deallocated")
    }

    init(releaseUrlString: String) {
        self.releaseUrlString = releaseUrlString
    }
}
