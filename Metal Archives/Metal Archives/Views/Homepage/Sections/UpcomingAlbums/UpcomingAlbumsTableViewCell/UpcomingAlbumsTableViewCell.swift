//
//  UpcomingAlbumsTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class UpcomingAlbumsTableViewCell: BaseTableViewCell, RegisterableCell {
    //MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var seeAllButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorView: UIView!
    
    var seeAll: (() -> Void)?
    var didSelectUpcomingAlbum: ((_ upcomingAlbum: UpcomingAlbum) -> Void)?
    var didSelectImageView: ((_ imageView: UIImageView, _ urlString: String?, _ description: String) -> Void)?
    
    var upcomingAlbums = [UpcomingAlbum]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UpcomingAlbumCollectionViewCell.register(with: collectionView)
        collectionView.contentInset = Settings.collectionViewContentInset
        collectionView.decelerationRate = .fast
        collectionViewHeightConstraint.constant = calculateCollectionViewHeight(cellHeight: Settings.upcomingAlbumCollectionViewCellHeight, itemPerRow: Settings.numberOfGeneralItemPerRow)
    }
    
    override func initAppearance() {
        super.initAppearance()
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.font = Settings.currentFontSize.largeTitleFont
        
        seeAllButton.setTitleColor(Settings.currentTheme.titleColor, for: .normal)
        seeAllButton.titleLabel?.font = Settings.currentFontSize.secondaryTitleFont
        
        backgroundColor = Settings.currentTheme.backgroundColor
        collectionView.backgroundColor = Settings.currentTheme.backgroundColor
        
        separatorView.backgroundColor = Settings.currentTheme.collectionViewSeparatorColor
    }
    
    @IBAction private func didTapSeeAllButton() {
        seeAll?()
    }
}

//MARK: - UICollectionViewDataSource
extension UpcomingAlbumsTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UpcomingAlbumCollectionViewCell.dequeueFrom(collectionView, forIndexPath: indexPath)
        let upcomingAlbum = upcomingAlbums[indexPath.item]
        cell.fill(with: upcomingAlbum)
        cell.showSeparator((indexPath.item + 1) % Settings.numberOfGeneralItemPerRow == 0)
        
        cell.tappedThumbnailImageView = { [unowned self] in
            self.didSelectImageView?(cell.thumbnailImageView, upcomingAlbum.release.imageURLString, upcomingAlbum.release.title)
        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension UpcomingAlbumsTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectUpcomingAlbum?(upcomingAlbums[indexPath.item])
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension UpcomingAlbumsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: Settings.collectionViewCellWidth, height: Settings.upcomingAlbumCollectionViewCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Settings.collectionViewItemSpacing
    }
}
