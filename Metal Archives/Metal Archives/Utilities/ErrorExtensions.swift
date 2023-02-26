//
//  ErrorExtensions.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import Foundation

extension Error {
    var userFacingMessage: String {
        if let maError = self as? MAError {
            return maError.description
        }
        return localizedDescription
    }
}
