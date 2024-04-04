//
//  ArtistTriviaViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/04/2024.
//

import Factory
import Foundation

@MainActor
final class ArtistTriviaViewModel: ObservableObject {
    @Published private(set) var state: State = .loading

    enum State: Equatable {
        case loading
        case loaded(String)
        case error(Error)

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                true
            case let (.loaded(lString), .loaded(rString)):
                lString == rString
            case let (.error(lError), .error(rError)):
                lError.localizedDescription == rError.localizedDescription
            default:
                false
            }
        }

        var isLoaded: Bool {
            if case .loaded = self {
                return true
            }
            return false
        }
    }

    private let urlString: String
    private let apiService = resolve(\DependenciesContainer.apiService)

    init(urlString: String) {
        self.urlString = urlString
    }

    func loadTrivia() async {
        do {
            guard let id = urlString.components(separatedBy: "/").last else {
                throw MAError.failedToExtractArtistId(urlString)
            }
            state = .loading
            let urlString = "https://www.metal-archives.com/artist/read-more/id/\(id)/field/trivia"
            guard let trivia = try await apiService.getString(for: urlString, inHtmlFormat: false) else {
                throw MAError.failedToDecodeArtistTrivia
            }
            state = .loaded(trivia)
        } catch {
            state = .error(error)
        }
    }
}
