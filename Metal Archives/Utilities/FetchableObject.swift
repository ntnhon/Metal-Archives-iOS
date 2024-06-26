//
//  FetchableObject.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/06/2021.
//

import Foundation

enum FetchableObject<T> {
    case error(Error)
    case fetching
    case fetched(T)
}
