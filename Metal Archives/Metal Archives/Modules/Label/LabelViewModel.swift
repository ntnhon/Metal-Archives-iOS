//
//  LabelViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/10/2022.
//

import Kingfisher
import SwiftUI

final class LabelViewModel: ObservableObject {
//    deinit { print("\(Self.self) of \(urlString) is deallocated") }
    @Published private(set) var labelFetchable: FetchableObject<LabelDetail> = .fetching
    @Published private(set) var logoFetchable: FetchableObject<UIImage?> = .fetching

    let apiService: APIServiceProtocol
    private let urlString: String

    var label: LabelDetail? {
        switch labelFetchable {
        case .fetched(let label):
            return label
        default:
            return nil
        }
    }

    var logo: UIImage? {
        switch logoFetchable {
        case .fetched(let logo):
            return logo
        default:
            return nil
        }
    }

    init(apiService: APIServiceProtocol, urlString: String) {
        self.apiService = apiService
        self.urlString = urlString
    }

    @MainActor
    func fetchLabel() async {
        if case .fetched = labelFetchable { return }
        do {
            labelFetchable = .fetching
            let label = try await apiService.request(forType: LabelDetail.self, urlString: urlString)
            labelFetchable = .fetched(label)
        } catch {
            labelFetchable = .error(error)
        }
    }

    @MainActor
    func fetchLogo() async {
        guard let urlString = label?.logoUrlString,
              let url = URL(string: urlString) else {
            return
        }
        do {
            logoFetchable = .fetching
            let photo = try await KingfisherManager.shared.retrieveImage(with: url)
            logoFetchable = .fetched(photo)
        } catch {
            logoFetchable = .error(error)
        }
    }
}
