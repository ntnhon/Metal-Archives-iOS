//
//  ReleaseLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReleaseLite: ThumbnailableObject {
    let title: String
    let type: ReleaseType
    let year: Int
    let numberOfReviews: Int?
    let rating: Int?
    let reviewsURLString: String?
    
    lazy var isPlatinium: Bool = {
        guard let numberOfReviews = numberOfReviews, let rating = rating else { return false }
        return numberOfReviews >= 10 && rating >= 75
    }()
    
    lazy var attributedDescription: NSAttributedString = {
        let reviewString: String?
        if let numberOfReviews = numberOfReviews, let rating = rating {
            reviewString = "\(numberOfReviews) (\(rating)%)"
        } else {
            reviewString = nil
        }
        
        var string: String
        if let reviewString = reviewString {
            string = "\(year) • \(type.description) • \(reviewString)"
        } else {
            string = "\(year) • \(type.description)"
        }
        
        if isPlatinium {
            string += " 🏅"
        }
        
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes([
            .foregroundColor: Settings.currentTheme.bodyTextColor,
            .font: Settings.currentFontSize.bodyTextFont],range: NSRange(string.startIndex..., in: string))
        
        // Review & rating styling
        if let reviewString = reviewString, let rating = rating, let range = string.range(of: reviewString) {
            attributedString.addAttribute(.foregroundColor, value: UIColor.colorByRating(rating), range: NSRange(range, in: string))
        }
        
        // Release type styling
        if let range = string.range(of: type.description) {
            let font: UIFont
            switch type {
            case .fullLength: font = Settings.currentFontSize.heavyBodyTextFont
            case .demo: font = Settings.currentFontSize.italicBodyTextFont
            case .single: font = Settings.currentFontSize.tertiaryFont
            default: font = Settings.currentFontSize.bodyTextFont
            }
            
            attributedString.addAttribute(.font, value: font, range: NSRange(range, in: string))
        }
        
        // Year styling
        if let range = string.range(of: "\(year)") {
            let font: UIFont
            switch type {
            case .fullLength: font = Settings.currentFontSize.heavyBodyTextFont
            default: font = Settings.currentFontSize.bodyTextFont
            }
            
            attributedString.addAttribute(.font, value: font, range: NSRange(range, in: string))
        }
        
        return attributedString
    }()
    
    init?(urlString: String, type: ReleaseType, title: String, year: Int, numberOfReviews: Int?, rating: Int?, reviewsURLString: String?) {
        self.title = title
        self.year = year
        self.type = type
        self.numberOfReviews = numberOfReviews
        self.rating = rating
        self.reviewsURLString = reviewsURLString
        super.init(urlString: urlString, imageType: .release)
    }
}

extension ReleaseLite {
    override var generalDescription: String {
        return "\(id) - \(title) - \(year) - \(type.description)"
    }
}
