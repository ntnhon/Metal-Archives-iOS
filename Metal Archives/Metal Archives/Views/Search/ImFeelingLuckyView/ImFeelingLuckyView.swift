//
//  ImFeelingLuckyView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 04/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

protocol ImFeelingLuckyViewDelegate {
    func didTapImFeelingLuckyButton()
}

final class ImFeelingLuckyView: UIView {
    @IBOutlet private weak var imFeelingLuckyButton: UIButton!
    var delegate: ImFeelingLuckyViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 44)
        
        self.imFeelingLuckyButton.backgroundColor = self.tintColor
        self.imFeelingLuckyButton.setTitleColor(.white, for: .normal)
        self.imFeelingLuckyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }
    
    @IBAction private func didTapButton() {
        self.delegate?.didTapImFeelingLuckyButton()
    }
}
