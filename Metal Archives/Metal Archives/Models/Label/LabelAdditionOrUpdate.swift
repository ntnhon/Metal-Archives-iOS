//
//  LabelAdditionOrUpdate.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

class LabelAdditionOrUpdate: Thumbnailable {
    let name: String
    let status: LabelStatus
    let country: Country?
    let updatedDate: Date
    
    init?(urlString: String, name: String, status: LabelStatus, country: Country?, updatedDate: Date) {
        self.name = name
        self.status = status
        self.country = country
        self.updatedDate = updatedDate
        super.init(urlString: urlString, imageType: .label)
    }
}
