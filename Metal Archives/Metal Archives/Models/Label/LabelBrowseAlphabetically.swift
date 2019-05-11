//
//  LabelBrowseAlphabetically.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class LabelBrowseAlphabetically: ThumbnailableObject {
    let name: String
    let specialisation: String
    let status: LabelStatus
    let country: Country?
    let websiteURLString: String?
    let onlineShopping: Bool
    
    init?(urlString: String, name: String, specialisation: String, status: LabelStatus, country: Country?, websiteURLString: String?, onlineShopping: Bool) {
        self.name = name
        self.specialisation = specialisation
        self.status = status
        self.country = country
        self.websiteURLString = websiteURLString
        self.onlineShopping = onlineShopping
        super.init(urlString: urlString, imageType: .label)
    }
}

//MARK: - Pagable
extension LabelBrowseAlphabetically: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/label/ajax-list/json/1/l/<LETTER>?sEcho=1&iColumns=7&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&mDataProp_6=6&iSortCol_0=1&sSortDir_0=asc&iSortingCols=1&bSortable_0=false&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=false&bSortable_6=true"
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [LabelBrowseAlphabetically]?, totalRecords: Int?)? {
        var list: [LabelBrowseAlphabetically] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listLabelBrowseAlphabetically = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listLabelBrowseAlphabetically.forEach { (labelDetails) in
            var name: String?
            if let nameSubString = labelDetails[1].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                name = String(nameSubString)
            }
            
            var urlString: String?
            if let urlSubString = labelDetails[1].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                urlString = String(urlSubString)
            }
            
            let specialisation = labelDetails[2].replacingOccurrences(of: " &nbsp;", with: "")
            
            var status: LabelStatus?
            if let statusSubString = labelDetails[3].subString(after: "\">", before: "</span>", options: .caseInsensitive) {
                status = LabelStatus(statusString: String(statusSubString))
            }
        
            let countryName = labelDetails[4].replacingOccurrences(of: "&nbsp;", with: "")
            let country = Country(name: countryName)
            
            var websiteURLString: String?
            if let websiteURLSubString = labelDetails[5].subString(after: "href='", before: "' title=", options: .caseInsensitive) {
                websiteURLString = String(websiteURLSubString)
            }
            
            var onlineShopping = false
            if labelDetails[6] != "&nbsp;" {
                onlineShopping = true
            }
            
            if let `name` = name, let `urlString` = urlString, let `status` = status {
                if let label = LabelBrowseAlphabetically(urlString: urlString, name: name, specialisation: specialisation, status: status, country: country, websiteURLString: websiteURLString, onlineShopping: onlineShopping) {
                    list.append(label)
                }
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}

//MARK: - Actionable
extension LabelBrowseAlphabetically: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        let labelElement = ActionableElement(name: self.name, urlString: self.urlString, type: .label)
        elements.append(labelElement)
        
        if let websiteURLString = self.websiteURLString {
            let websiteElement = ActionableElement(name: "\(self.name)'s site", urlString: websiteURLString, type: .website)
            elements.append(websiteElement)
        }
        
        return elements
    }
}
