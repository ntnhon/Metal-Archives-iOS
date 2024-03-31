//
//  OpenURLAction+OpenUrlString.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 31/03/2024.
//

import SwiftUI

extension OpenURLAction {
    func callAsFunction(urlString: String) {
        guard let url = URL(string: urlString) else {
            assertionFailure("Bad URL string \(urlString)")
            return
        }
        callAsFunction(url)
    }
}
