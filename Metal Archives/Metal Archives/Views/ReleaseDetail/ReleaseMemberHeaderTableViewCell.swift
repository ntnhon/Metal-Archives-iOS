//
//  ReleaseMemberHeaderTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import BetterSegmentedControl

protocol ReleaseMemberHeaderTableViewCellDelegate {
    func lineUpTypeChanged(_ lineUpTypeIndex: Int)
}

final class ReleaseMemberHeaderTableViewCell: BaseTableViewCell, RegisterableCell {
    private var betterSegmentedControl: BetterSegmentedControl!
    var delegate: ReleaseMemberHeaderTableViewCellDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.backgroundColor = Settings.currentTheme.backgroundColor
        self.backgroundColor = Settings.currentTheme.backgroundColor
        self.contentView.heightAnchor.constraint(equalToConstant: Settings.segmentedHeaderHeight).isActive = true
        self.layoutIfNeeded()
    }
    
    func initSegmentControl(availableLineupTypes: [LineUpType]) {
        let segmentsTitles = availableLineupTypes.map{ $0.description }
        
        self.betterSegmentedControl = BetterSegmentedControl(
            frame: CGRect(x: 0, y: 0, width: 0, height: 30),
            segments: LabelSegment.segments(withTitles: segmentsTitles,
                                            normalFont: UIFont.systemFont(ofSize: 13, weight: .regular),
                                            normalTextColor: Settings.currentTheme.segmentNormalTextColor,
                                            selectedFont: UIFont.systemFont(ofSize: 15, weight: .bold),
                                            selectedTextColor: Settings.currentTheme.segmentSelectedTextColor),
            options:[.backgroundColor(Settings.currentTheme.secondaryTitleColor),
                     .indicatorViewBackgroundColor(Settings.currentTheme.titleColor),
                     .cornerRadius(3.0),
                     .bouncesOnChange(false)])
        
        self.betterSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        //Set "Band Member" as default display type
        self.betterSegmentedControl.setIndex(1)
        
        self.betterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.betterSegmentedControl)
        NSLayoutConstraint.activate([
            self.betterSegmentedControl.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.betterSegmentedControl.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.betterSegmentedControl.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.betterSegmentedControl.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
            ])
        
    }
    
    @objc private func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        self.delegate?.lineUpTypeChanged(Int(sender.index))
    }
}
