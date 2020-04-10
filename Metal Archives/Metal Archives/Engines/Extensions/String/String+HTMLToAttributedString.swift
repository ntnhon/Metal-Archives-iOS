//
//  String+HTMLToAttributedString.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 28/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension String {
    func htmlToAttributedString(attributes: [NSAttributedString.Key : Any]? = nil) -> NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        
        do {
            let mutableAttributedString = try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            
            if let attributes = attributes {
                mutableAttributedString.addAttributes(attributes, range: NSRange(mutableAttributedString.string.startIndex..., in: mutableAttributedString.string))
            }
            
            return mutableAttributedString
            
        } catch {
            return nil
        }
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var htmlToString: String? {
        return htmlToAttributedString?.string
    }
}
