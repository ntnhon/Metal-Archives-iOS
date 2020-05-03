//
//  LabelBrowseAlphabetically.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class LabelBrowseAlphabetically: ThumbnailableObject, Pagable {
    let name: String
    let specialisation: String
    let status: LabelStatus
    let country: Country
    let websiteURLString: String?
    let onlineShopping: Bool
    
    static var rawRequestURLString = "https://www.metal-archives.com/label/ajax-list/json/1/l/<LETTER>?sEcho=1&iColumns=7&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&mDataProp_6=6&iSortCol_0=1&sSortDir_0=asc&iSortingCols=1&bSortable_0=false&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=false&bSortable_6=true"
    
    static var displayLength = 200
    
    init?(from array: [String]) {
        var name: String?
        if let nameSubString = array[1].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
            name = String(nameSubString)
        }
        
        var urlString: String?
        if let urlSubString = array[1].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
            urlString = String(urlSubString)
        }
        
        let specialisation = array[2].replacingOccurrences(of: " &nbsp;", with: "")
        
        var status: LabelStatus?
        if let statusSubString = array[3].subString(after: "\">", before: "</span>", options: .caseInsensitive) {
            status = LabelStatus(statusString: String(statusSubString))
        }
        
        let countryName = array[4].replacingOccurrences(of: "&nbsp;", with: "")
        let country = Country(name: countryName)
        
        var websiteURLString: String?
        if let websiteURLSubString = array[5].subString(after: "href='", before: "' title=", options: .caseInsensitive) {
            websiteURLString = String(websiteURLSubString)
        }
        
        var onlineShopping = false
        if array[6] != "&nbsp;" {
            onlineShopping = true
        }
        
        if let name = name, let urlString = urlString, let status = status {
            self.name = name
            self.specialisation = specialisation
            self.status = status
            self.country = country
            self.websiteURLString = websiteURLString
            self.onlineShopping = onlineShopping
            super.init(urlString: urlString, imageType: .label)
        } else {
            return nil
        }
    }
}

//MARK: - Actionable
extension LabelBrowseAlphabetically: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        let labelElement = ActionableElement.label(name: name, urlString: urlString)
        elements.append(labelElement)
        
        if let websiteURLString = self.websiteURLString {
            let websiteElement = ActionableElement.website(name: "\(self.name)'s site", urlString: websiteURLString)
            elements.append(websiteElement)
        }
        
        return elements
    }
}
