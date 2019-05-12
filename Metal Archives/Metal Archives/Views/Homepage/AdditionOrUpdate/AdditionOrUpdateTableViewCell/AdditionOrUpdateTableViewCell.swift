//
//  AdditionOrUpdateTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class AdditionOrUpdateTableViewCell: BaseTableViewCell, RegisterableCell {
    enum Mode {
        case additions, updates
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var seeAllButton: UIButton!
    @IBOutlet private weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorView: UIView!
    
    var mode: AdditionOrUpdateTableViewCell.Mode = .additions
    
    var seeAll: (() -> Void)?
    var changeType: ((_ type: AdditionOrUpdateType) -> Void)?
    var didSelectBand: ((_ band: BandAdditionOrUpdate) -> Void)?
    
    var bands = [BandAdditionOrUpdate]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var labels = [LabelAdditionOrUpdate]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var artist = [ArtistAdditionOrUpdate]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        BandAdditionOrUpdateCollectionViewCell.register(with: collectionView)
        collectionView.contentInset = Settings.collectionViewContentInset
        collectionView.decelerationRate = .fast
        collectionViewHeightConstraint.constant = calculateCollectionViewHeight(cellHeight: Settings.generalCollectionViewCellHeight, itemPerRow: Settings.numberOfGeneralItemPerRow)
    }
    
    
    override func initAppearance() {
        super.initAppearance()
        
        titleLabel.textColor = Settings.currentTheme.bodyTextColor
        titleLabel.font = Settings.currentFontSize.largeTitleFont
        
        seeAllButton.setTitleColor(Settings.currentTheme.titleColor, for: .normal)
        seeAllButton.titleLabel?.font = Settings.currentFontSize.secondaryTitleFont
        
        backgroundColor = Settings.currentTheme.backgroundColor
        collectionView.backgroundColor = Settings.currentTheme.backgroundColor
        
        typeSegmentedControl.tintColor = Settings.currentTheme.iconTintColor
        
        separatorView.backgroundColor = Settings.currentTheme.collectionViewSeparatorColor
    }
    
    @IBAction private func didTapSeeAllButton() {
        seeAll?()
    }
    
}

//MARK: - UICollectionViewDataSource
extension AdditionOrUpdateTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bands.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = BandAdditionOrUpdateCollectionViewCell.dequeueFrom(collectionView, forIndexPath: indexPath)
        cell.fill(with: bands[indexPath.item])
        cell.showSeparator((indexPath.item + 1) % Settings.numberOfGeneralItemPerRow == 0)
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension AdditionOrUpdateTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectBand?(bands[indexPath.item])
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension AdditionOrUpdateTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: Settings.collectionViewCellWidth, height: Settings.generalCollectionViewCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Settings.collectionViewItemSpacing
    }
}
