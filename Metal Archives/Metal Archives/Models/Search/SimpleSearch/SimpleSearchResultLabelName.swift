//
//  SimpleSearchResultLabelName.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultLabelName: Pagable {
    let label: LabelLite
    let aka: String?
    let country: Country?
    let specialisation: String
    
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-label-search/?field=name&query=<QUERY>&sEcho=5&iColumns=3&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2"
    
    static var displayLength = 200
    
    init?(from array: [String]) {
        var label: LabelLite?
        var aka: String?
        
        if array.indices.contains(0) {
            var labelName: String?
            var urlString: String?
            
            if let subString = array[0].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                labelName = String(subString)
            }
            
            if let subString = array[0].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                urlString = String(subString)
            }
            
            if array[0].contains("a.k.a") {
                if let subString = array[0].subString(after: "</a> (", before: ")", options: .caseInsensitive) {
                    aka = subString.replacingOccurrences(of: "<strong>", with: "").replacingOccurrences(of: "</strong>", with: "")
                    
                }
            }
            
            if let `labelName` = labelName, let `urlString` = urlString {
                label = LabelLite(urlString: urlString, name: labelName)
            }
        }
        
        let countryName: String? = array.indices.contains(1) ? array[1] : nil
        var country: Country?
        if let countryName = countryName {
            country = Country(name: countryName)
        }
        
        let specialisation: String? = array.indices.contains(2) ? array[2] : nil
        
        if let label = label, let specialisation = specialisation {
            self.label = label
            self.aka = aka
            self.country = country
            self.specialisation = specialisation
        } else {
            return nil
        }
    }
}
