//
//  ReleaseOtherVersion.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ReleaseOtherVersion {
    let id: String
    let urlString: String
    let dateString: String
    let labelName: String
    let catalogID: String?
    let additionalDetail: String //Ex: "Unofficial"
    let format: String
    let description: String?
    
    init?(urlString: String, dateString: String, additionalDetail: String, labelName: String, catalogID: String, format: String, description: String) {
        guard let id = urlString.components(separatedBy: "/").last else {
            return nil
        }
        
        self.id = id
        self.urlString = urlString
        self.dateString = dateString
        self.additionalDetail = additionalDetail
        self.labelName = labelName
        
        if catalogID == "" {
            self.catalogID = nil
        } else {
            self.catalogID = catalogID
        }
        
        self.format = format
        
        if description == "" {
            self.description = nil
        } else {
            self.description = description
        }
    }
}
