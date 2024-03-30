//
//  LabelViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/10/2022.
//

import Kingfisher
import SwiftUI

@MainActor
final class LabelViewModel: ObservableObject {
//    deinit { print("\(Self.self) of \(urlString) is deallocated") }
    @Published private(set) var labelFetchable: FetchableObject<LabelDetail> = .fetching
    @Published private(set) var logoFetchable: FetchableObject<UIImage?> = .fetching
    @Published private(set) var relatedLinksFetchable: FetchableObject<[RelatedLink]> = .fetching

    let apiService: APIServiceProtocol
    let urlString: String

    var label: LabelDetail? {
        switch labelFetchable {
        case let .fetched(label):
            return label
        default:
            return nil
        }
    }

    var logo: UIImage? {
        switch logoFetchable {
        case let .fetched(logo):
            return logo
        default:
            return nil
        }
    }

    init(apiService: APIServiceProtocol, urlString: String) {
        self.apiService = apiService
        self.urlString = urlString
    }

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

    func fetchLogo() async {
        guard let urlString = label?.logoUrlString,
              let url = URL(string: urlString)
        else {
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

    func fetchRelatedLinks(forceRefresh: Bool) async {
        guard let labelId = urlString.components(separatedBy: "/").last else { return }
        if !forceRefresh, case .fetched = relatedLinksFetchable { return }

        let urlString = "https://www.metal-archives.com/link/ajax-list/type/label/id/\(labelId)"
        relatedLinksFetchable = .fetching
        do {
            let links = try await apiService.request(forType: RelatedLinkArray.self,
                                                     urlString: urlString)
            relatedLinksFetchable = .fetched(links.content)
        } catch {
            relatedLinksFetchable = .error(error)
        }
    }
}
