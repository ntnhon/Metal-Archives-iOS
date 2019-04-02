//
//  SimpleSearchResultLabelName.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultLabelName {
    let label: LabelLite
    let aka: String?
    let country: Country?
    let specialisation: String
    
    init(label: LabelLite, aka: String?, country: Country?, specialisation: String) {
        self.label = label
        self.aka = aka
        self.country = country
        self.specialisation = specialisation
    }
}

extension SimpleSearchResultLabelName: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-label-search/?field=name&query=<QUERY>&sEcho=5&iColumns=3&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2"
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [SimpleSearchResultLabelName]?, totalRecords: Int?)? {
        var list: [SimpleSearchResultLabelName] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listSimpleSearchResultLabelName = json?["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json?["iTotalRecords"] as? Int
        
        listSimpleSearchResultLabelName.forEach { (eachDetail) in
            var label: LabelLite?
            var aka: String?
            
            if eachDetail.indices.contains(0) {
                var labelName: String?
                var urlString: String?
                
                if let subString = eachDetail[0].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                    labelName = String(subString)
                }
                
                if let subString = eachDetail[0].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                    urlString = String(subString)
                }
                
                if eachDetail[0].contains("a.k.a") {
                    if let subString = eachDetail[0].subString(after: "</a> (", before: ")", options: .caseInsensitive) {
                        aka = subString.replacingOccurrences(of: "<strong>", with: "").replacingOccurrences(of: "</strong>", with: "")
                        
                    }
                }
                
                if let `labelName` = labelName, let `urlString` = urlString {
                    label = LabelLite(urlString: urlString, name: labelName)
                }
            }
            
            let countryName: String? = eachDetail.indices.contains(1) ? eachDetail[1] : nil
            var country: Country?
            if let `countryName` = countryName {
                country = Country(name: countryName)
            }
            
            let specialisation: String? = eachDetail.indices.contains(2) ? eachDetail[2] : nil
            
            if let `label` = label, let `specialisation` = specialisation {
                let result = SimpleSearchResultLabelName(label: label, aka: aka, country: country, specialisation: specialisation)
                list.append(result)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
