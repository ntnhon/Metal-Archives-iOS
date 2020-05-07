//
//  Utilities.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

func openReviewOnAppStore() {
    let appStoreURLString = "https://itunes.apple.com/app/id1074038930?action=write-review"
    UIApplication.shared.open(URL(string: appStoreURLString)!, options: [:]) { (finished) in
        Analytics.logEvent("made_a_review", parameters: nil)
    }
}

func calculateCollectionViewHeight(cellHeight: CGFloat,itemPerRow: Int) -> CGFloat {
    guard itemPerRow > 0 else {
        fatalError("Item per row for collection view must be greater than 0")
    }
    
    //let totalItemSpacing = Settings.collectionViewItemSpacing * CGFloat(itemPerRow - 1)
    //Workaround
    let totalItemSpacing = Settings.collectionViewItemSpacing * CGFloat(itemPerRow - 1) + 4 //4 is magic number
    return ceil(cellHeight * CGFloat(itemPerRow) + Settings.collectionViewContentInset.top + Settings.collectionViewContentInset.bottom + totalItemSpacing)
}
