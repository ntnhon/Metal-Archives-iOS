//
//  ArtistViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import Combine

final class ArtistViewModel: ObservableObject {
    private(set) var artist: Artist?
    private var cancellables = Set<AnyCancellable>()
    private let artistUrlString: String

    deinit {
        print("\(Self.self) of \(artistUrlString) is deallocated")
    }

    init(artistUrlString: String) {
        self.artistUrlString = artistUrlString
    }
}
