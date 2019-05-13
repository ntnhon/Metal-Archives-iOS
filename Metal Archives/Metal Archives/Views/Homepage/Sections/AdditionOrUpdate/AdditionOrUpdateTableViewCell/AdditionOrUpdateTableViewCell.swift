//
//  AdditionOrUpdateTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class AdditionOrUpdateTableViewCell: BaseTableViewCell, RegisterableCell {
    //MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var seeAllButton: UIButton!
    @IBOutlet private weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorView: UIView!
    
    //MARK: - Associated variables
    enum Mode {
        case additions, updates
    }
    var mode: AdditionOrUpdateTableViewCell.Mode = .additions {
        didSet {
            switch mode {
            case .additions: titleLabel.text = "Latest Additions"
            case .updates: titleLabel.text = "Latest Updates"
            }
        }
    }
    
    var seeAll: (() -> Void)?
    var changeType: ((_ type: AdditionOrUpdateType) -> Void)?
    var didSelectBand: ((_ band: BandAdditionOrUpdate) -> Void)?
    var didSelectLabel: ((_ label: LabelAdditionOrUpdate) -> Void)?
    var didSelectArtist: ((_ artist: ArtistAdditionOrUpdate) -> Void)?
    
    //MARK: - Dependencies
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
    
    var artists = [ArtistAdditionOrUpdate]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedType: AdditionOrUpdateType!
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        BandAdditionOrUpdateCollectionViewCell.register(with: collectionView)
        LabelAdditionOrUpdateCollectionViewCell.register(with: collectionView)
        ArtistAdditionOrUpdateCollectionViewCell.register(with: collectionView)
        
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
    
    @IBAction private func typeSegmentedControlValueChanged() {
        selectedType = AdditionOrUpdateType(rawValue: typeSegmentedControl.selectedSegmentIndex) ?? .bands
        changeType?(selectedType)
    }
}

//MARK: - UICollectionViewDataSource
extension AdditionOrUpdateTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedType! {
        case .bands: return bands.count
        case .labels: return labels.count
        case .artists: return artists.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch selectedType! {
        case .bands:
            let cell = BandAdditionOrUpdateCollectionViewCell.dequeueFrom(collectionView, forIndexPath: indexPath)
            cell.fill(with: bands[indexPath.item])
            cell.showSeparator((indexPath.item + 1) % Settings.numberOfGeneralItemPerRow == 0)
            return cell
        case .labels:
            let cell = LabelAdditionOrUpdateCollectionViewCell.dequeueFrom(collectionView, forIndexPath: indexPath)
            cell.fill(with: labels[indexPath.item])
            cell.showSeparator((indexPath.item + 1) % Settings.numberOfGeneralItemPerRow == 0)
            return cell
        case .artists:
            let cell = ArtistAdditionOrUpdateCollectionViewCell.dequeueFrom(collectionView, forIndexPath: indexPath)
            cell.fill(with: artists[indexPath.item])
            cell.showSeparator((indexPath.item + 1) % Settings.numberOfGeneralItemPerRow == 0)
            return cell
        }
    }
}

//MARK: - UICollectionViewDelegate
extension AdditionOrUpdateTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch selectedType! {
        case .bands: didSelectBand?(bands[indexPath.item])
        case .labels: didSelectLabel?(labels[indexPath.item])
        case .artists: didSelectArtist?(artists[indexPath.item])
        }
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

//MARK: - HomepageViewControllerLatestAdditionDelegate
extension AdditionOrUpdateTableViewCell: HomepageViewControllerLatestAdditionOrUpdateDelegate {
    func didFinishFetchingBandAdditionOrUpdate(_ bands: [BandAdditionOrUpdate]) {
        self.bands = bands
    }
    
    func didFinishFetchingLabelAdditionOrUpdate(_ labels: [LabelAdditionOrUpdate]) {
        self.labels = labels
    }
    
    func didFinishFetchingArtistAdditionOrUpdate(_ artists: [ArtistAdditionOrUpdate]) {
        self.artists = artists
    }
    
    func didFailFetching() {
        
    }
}
