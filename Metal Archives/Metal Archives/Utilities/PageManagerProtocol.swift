//
//  PageManager.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 03/10/2022.
//

import Foundation

let kDefaultPageSize = 200
let kDisplayStartPlaceholder = "<DISPLAY_START>"
let kDisplayLengthPlaceholder = "<DISPLAY_LENGTH>"
let kMaUrlQueryAllowedCharacterSet: CharacterSet = {
    let characterSet = NSMutableCharacterSet()
    characterSet.formUnion(with: CharacterSet.urlQueryAllowed)
    characterSet.addCharacters(in: "[]")
    return characterSet as CharacterSet
}()

enum PageElementError: Error {
    case badCount(count: Int, expectedCount: Int)
    case aTagNotFound(String)
    case hrefNotFound(String)
    case textNotFound(String)
}

protocol PageElement {
    init(from strings: [String]) throws
}

enum PageConfigsError: Error {
    case missingDisplayStart(String)
    case missingDisplayLength(String)
    case failedToAddPercentEncoding(String)
}

struct PageConfigs {
    let baseUrlString: String

    func urlString(page: Int, options: [String: String]) throws -> String {
        guard baseUrlString.contains(kDisplayStartPlaceholder) else {
            throw PageConfigsError.missingDisplayStart(baseUrlString)
        }

        guard baseUrlString.contains(kDisplayLengthPlaceholder) else {
            throw PageConfigsError.missingDisplayLength(baseUrlString)
        }

        var urlString = baseUrlString
        let displayStart = page * kDefaultPageSize

        urlString = urlString.replacingOccurrences(of: kDisplayStartPlaceholder, with: "\(displayStart)")
        urlString = urlString.replacingOccurrences(of: kDisplayLengthPlaceholder, with: "\(kDefaultPageSize)")

        options.forEach { key, value in
            urlString = urlString.replacingOccurrences(of: key, with: value)
        }

        guard let formattedUrlString =
                urlString.addingPercentEncoding(withAllowedCharacters: kMaUrlQueryAllowedCharacterSet) else {
            throw PageConfigsError.failedToAddPercentEncoding(urlString)
        }

        return formattedUrlString
    }
}

struct PageResult<Element: PageElement>: Decodable {
    let total: Int
    let elements: [Element]

    enum CodingKeys: String, CodingKey {
        case total = "iTotalRecords"
        case data = "aaData"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.total = try container.decode(Int.self, forKey: .total)
        let data = try container.decode([[String]].self, forKey: .data)
        self.elements = try data.map { try Element(from: $0) }
    }
}

protocol PageManagerProtocol {
    associatedtype Element: PageElement

    var configs: PageConfigs { get }
    var apiService: APIServiceProtocol { get }

    func getElements(page: Int, options: [String: String]) async throws -> PageResult<Element>
}

extension PageManagerProtocol {
    func getElements(page: Int, options: [String: String]) async throws -> PageResult<Element> {
        let urlString = try configs.urlString(page: page, options: options)
        let data = try await apiService.getData(for: urlString)
        return try JSONDecoder().decode(PageResult<Element>.self, from: data)
    }
}

class PageManager<Element: PageElement>: PageManagerProtocol {
    @Published private(set) var elements = [Element]()
    @Published private(set) var isLoading = false
    private var currentPage = 0
    private var moreToLoad = true
    let configs: PageConfigs
    let apiService: APIServiceProtocol

    init(configs: PageConfigs, apiService: APIServiceProtocol) {
        self.configs = configs
        self.apiService = apiService
    }

    func getMoreElements(options: [String: String] = [:]) async throws {
        guard moreToLoad else { return }
        isLoading = true
        let results = try await getElements(page: currentPage, options: options)
        elements.append(contentsOf: results.elements)
        isLoading = false
        currentPage += 1
        moreToLoad = elements.count < results.total
    }
}
