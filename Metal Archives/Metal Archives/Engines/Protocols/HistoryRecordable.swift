//
//  HistoryRecordable.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

protocol HistoryRecordable {
    func loaded(withNameOrTitle nameOrTitle: String, thumbnailUrlString: String?)
}
