//
//  DeezerData.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

struct DeezerData<T: Decodable>: Decodable {
    let data: [T]
}
