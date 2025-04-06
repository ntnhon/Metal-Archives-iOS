//
//  HTMLSanitizer.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 05/04/2024.
//

import Foundation

/// Sanitize HTML text into raw text (without HTML tags)
public protocol HTMLSanitizer: Sendable {
    func sanitize(html: String) -> String
}
