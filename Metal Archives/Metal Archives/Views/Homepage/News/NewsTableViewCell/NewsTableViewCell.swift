//
//  NewsTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class NewsTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var seeAllButton: UIButton!

    var newsArray = [News]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var seeAll: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NewsCollectionViewCell.register(with: collectionView)
        collectionView.contentInset = Settings.collectionViewContentInset
        collectionView.decelerationRate = .fast
        collectionViewHeightConstraint.constant = calculateCollectionViewHeight(cellHeight: Settings.newsCollectionViewCellHeight, itemPerRow: Settings.numberOfNewsItemPerRow)
        layoutIfNeeded()
    }
    
    override func initAppearance() {
        super.initAppearance()
        
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.font = Settings.currentFontSize.largeTitleFont
        
        seeAllButton.setTitleColor(Settings.currentTheme.titleColor, for: .normal)
        seeAllButton.titleLabel?.font = Settings.currentFontSize.secondaryTitleFont
        
        backgroundColor = Settings.currentTheme.backgroundColor
        collectionView.backgroundColor = Settings.currentTheme.backgroundColor
    }
    
    @IBAction private func didTapSeeAllButton() {
        seeAll?()
    }
}

extension NewsTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = NewsCollectionViewCell.dequeueFrom(collectionView, forIndexPath: indexPath)
        cell.fill(with: newsArray[indexPath.item])
        return cell
    }
}

extension NewsTableViewCell: UICollectionViewDelegate {
    
}

extension NewsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: Settings.collectionViewCellWidth, height: Settings.newsCollectionViewCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Settings.collectionViewItemSpacing
    }
}
