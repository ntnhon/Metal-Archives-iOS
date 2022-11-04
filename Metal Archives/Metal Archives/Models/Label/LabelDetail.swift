//
//  LabelDetail.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 03/11/2022.
//

import Foundation
import Kanna

struct LabelDetail {
    let logoUrlString: String?
    let name: String
    let address: String
    let country: Country
    let phoneNumber: String
    let status: LabelStatus
    let specialties: String
    let foundingDate: String
    let parentLabel: LabelLite?
    let subLabels: [LabelLite]
    let onlineShopping: String
    let isLastKnown: Bool
    let website: RelatedLink?
    let additionalNotes: String?
    let modificationInfo: ModificationInfo
}

extension LabelDetail {
    private enum InfoType {
        case address, country, phoneNumber, status, specialties
        case foundingDate, parentLabel, subLabels, onlineShopping

        init?(string: String) {
            let string = string.lowercased()
            if string.contains("address") {
                self = .address
            } else if string.contains("country") {
                self = .country
            } else if string.contains("number") {
                self = .phoneNumber
            } else if string.contains("status") {
                self = .status
            } else if string.contains("specialties") {
                self = .specialties
            } else if string.contains("date") {
                self = .foundingDate
            } else if string.contains("parent label") {
                self = .parentLabel
            } else if string.contains("sub-labels") {
                self = .subLabels
            } else if string.contains("shopping") {
                self = .onlineShopping
            } else {
                return nil
            }
        }
    }
}

extension LabelDetail {
    final class Builder {
        var logoUrlString: String?
        var name: String?
        var address: String?
        var country: Country?
        var phoneNumber: String?
        var status: LabelStatus?
        var specialties: String?
        var foundingDate: String?
        var parentLabel: LabelLite?
        var subLabels: [LabelLite] = []
        var onlineShopping: String?
        var isLastKnown = false
        var website: RelatedLink?
        var additionalNotes: String?
        var modificationInfo: ModificationInfo?

        func build() -> LabelDetail? {
            guard let name else {
                Logger.log("[Building LabelDetail] name can not be nil")
                return nil
            }

            guard let address else {
                Logger.log("[Building LabelDetail] address can not be nil")
                return nil
            }

            guard let country else {
                Logger.log("[Building LabelDetail] country can not be nil")
                return nil
            }

            guard let phoneNumber else {
                Logger.log("[Building LabelDetail] phoneNumber can not be nil")
                return nil
            }

            guard let status else {
                Logger.log("[Building LabelDetail] status can not be nil")
                return nil
            }

            guard let specialties else {
                Logger.log("[Building LabelDetail] specialties can not be nil")
                return nil
            }

            guard let foundingDate else {
                Logger.log("[Building LabelDetail] foundingDate can not be nil")
                return nil
            }

            guard let onlineShopping else {
                Logger.log("[Building LabelDetail] onlineShopping can not be nil")
                return nil
            }

            guard let modificationInfo else {
                Logger.log("[Building LabelDetail] modificationInfo can not be nil")
                return nil
            }

            return .init(logoUrlString: logoUrlString,
                         name: name,
                         address: address,
                         country: country,
                         phoneNumber: phoneNumber,
                         status: status,
                         specialties: specialties,
                         foundingDate: foundingDate,
                         parentLabel: parentLabel,
                         subLabels: subLabels,
                         onlineShopping: onlineShopping,
                         isLastKnown: isLastKnown,
                         website: website,
                         additionalNotes: additionalNotes,
                         modificationInfo: modificationInfo)
        }
    }
}

extension LabelDetail: HTMLParsable {
    init(data: Data) throws {
        let html = try Kanna.HTML(html: data, encoding: .utf8)
        let builder = Builder()

        for div in html.css("div") {
            if div["class"] == "label_img" {
                builder.logoUrlString = div.at_css("a")?["href"]
            }

            switch div["id"] {
            case "label_info":
                Self.parseLabelInfo(from: div, builder: builder)
            case "label_tabs_notes":
                builder.additionalNotes = div.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            case "auditTrail":
                builder.modificationInfo = .init(element: div)
            default:
                break
            }
        }

        guard let label = builder.build() else {
            throw MAError.parseFailure("\(Self.self)")
        }
        self = label
    }

    private static func parseLabelInfo(from div: XMLElement, builder: Builder) {
        builder.name = div.at_css("h1")?.text

        var infoTypes = [LabelDetail.InfoType]()

        for dt in div.css("dt") {
            if let dtText = dt.text, let type = InfoType(string: dtText) {
                infoTypes.append(type)
            }
        }

        for (index, dd) in div.css("dd").enumerated() {
            guard let ddText = dd.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }

            switch infoTypes[index] {
            case .address: builder.address = ddText
            case .country: builder.country = CountryManager.shared.country(by: \.name, value: ddText)
            case .phoneNumber: builder.phoneNumber = ddText
            case .status: builder.status = .init(rawValue: ddText)
            case .specialties: builder.specialties = ddText
            case .foundingDate: builder.foundingDate = ddText
            case .parentLabel:
                if let aTag = dd.at_css("a") {
                    builder.parentLabel = .init(aTag: aTag)
                }
            case .subLabels: builder.subLabels = dd.css("a").compactMap { .init(aTag: $0) }
            case .onlineShopping: builder.onlineShopping = ddText
            }
        }
    }
}
