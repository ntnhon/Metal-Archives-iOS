//
//  HTMLParsable.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/06/2021.
//

import Foundation

protocol HTMLParsable: Sendable {
    init(data: Data) throws
}
