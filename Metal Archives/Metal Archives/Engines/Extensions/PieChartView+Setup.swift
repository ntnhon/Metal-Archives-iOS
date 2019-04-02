//
//  PieChartView+Setup.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Charts

extension PieChartView {
    func setup() {
        self.usePercentValuesEnabled = true
        self.drawSlicesUnderHoleEnabled = false
        self.holeRadiusPercent = 0.58
        self.transparentCircleRadiusPercent = 0.61
        self.chartDescription?.enabled = false
        self.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
        self.drawEntryLabelsEnabled = false
        self.usePercentValuesEnabled = true
        self.holeColor = Settings.currentTheme.backgroundColor
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        self.rotationAngle = 0
        self.rotationEnabled = true
        self.highlightPerTapEnabled = true
        
        let l = self.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.drawInside = false
        l.xEntrySpace = 7
        l.yEntrySpace = 0
        l.yOffset = 0
        l.textColor = Settings.currentTheme.bodyTextColor
    }
}

