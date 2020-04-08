//
//  LabelBrowseByCountry.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class LabelBrowseByCountry: ThumbnailableObject {
    let name: String
    let specialisation: String
    let status: LabelStatus
    let websiteURLString: String?
    let onlineShopping: Bool
    
    init?(urlString: String, name: String, specialisation: String, status: LabelStatus, websiteURLString: String?, onlineShopping: Bool) {
        self.name = name
        self.specialisation = specialisation
        self.status = status
        self.websiteURLString = websiteURLString
        self.onlineShopping = onlineShopping
        super.init(urlString: urlString, imageType: .label)
    }
}

//MARK: - Pagable
extension LabelBrowseByCountry: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/label/ajax-list/c/<COUNTRY>/json/1?sEcho=1&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&iSortCol_0=1&sSortDir_0=asc&iSortingCols=1&bSortable_0=false&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=false&bSortable_5=true&_=1553073795216"
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [LabelBrowseByCountry]?, totalRecords: Int?)? {
        var list: [LabelBrowseByCountry] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listLabelBrowseByCountry = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listLabelBrowseByCountry.forEach { (labelDetails) in
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
            
            var websiteURLString: String?
            if let websiteURLSubString = labelDetails[4].subString(after: "href='", before: "' title=", options: .caseInsensitive) {
                websiteURLString = String(websiteURLSubString)
            }
            
            var onlineShopping = false
            if labelDetails[5] != "&nbsp;" {
                onlineShopping = true
            }
            
            if let `name` = name, let `urlString` = urlString, let `status` = status {
                if let label = LabelBrowseByCountry(urlString: urlString, name: name, specialisation: specialisation, status: status, websiteURLString: websiteURLString, onlineShopping: onlineShopping) {
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
extension LabelBrowseByCountry: Actionable {
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
