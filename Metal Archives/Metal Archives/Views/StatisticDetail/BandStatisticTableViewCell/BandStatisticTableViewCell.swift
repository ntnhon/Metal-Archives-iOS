//
//  BandStatisticTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Charts

final class BandStatisticTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var pieChartView: PieChartView!
    @IBOutlet private weak var pieChartViewHeightConstraint: NSLayoutConstraint!
    
    override func initAppearance() {
        super.initAppearance()
        self.selectionStyle = .none
        self.pieChartView.setup()
        self.pieChartViewHeightConstraint.constant = screenHeight*2/3
    }
    
    func drawChart(forBandStatistic bandStatistic: BandStatistic) {
        let activeEntry = PieChartDataEntry(value: Double(bandStatistic.active.count), label: "\(bandStatistic.active.description) (\(bandStatistic.active.count.formattedWithSeparator))")
        let onHoldEntry = PieChartDataEntry(value: Double(bandStatistic.onHold.count), label: "\(bandStatistic.onHold.description) (\(bandStatistic.onHold.count.formattedWithSeparator))")
        let splitUpEntry = PieChartDataEntry(value: Double(bandStatistic.splitUp.count), label: "\(bandStatistic.splitUp.description) (\(bandStatistic.splitUp.count.formattedWithSeparator))")
        let changedNameEntry = PieChartDataEntry(value: Double(bandStatistic.changedName.count), label: "\(bandStatistic.changedName.description) (\(bandStatistic.changedName.count.formattedWithSeparator))")
        let unknownEntry = PieChartDataEntry(value: Double(bandStatistic.unknown.count), label: "\(bandStatistic.unknown.description) (\(bandStatistic.unknown.count.formattedWithSeparator))")
        
        
        let pieChartDataSet = PieChartDataSet(entries: [activeEntry, onHoldEntry, splitUpEntry, changedNameEntry, unknownEntry], label: "\(bandStatistic.total.formattedWithSeparator) approved bands")
        
        pieChartDataSet.colors = [bandStatistic.active.color, bandStatistic.onHold.color, bandStatistic.splitUp.color, bandStatistic.changedName.color, bandStatistic.unknown.color]
        
        let data = PieChartData(dataSet: pieChartDataSet)
        
        
        //Center text
        let centerText = "There is a total of \(bandStatistic.total.formattedWithSeparator) approved bands"
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        self.pieChartView.centerAttributedText = NSMutableAttributedString(string: centerText, attributes: ([.font: UIFont.systemFont(ofSize: 13, weight: .medium), .foregroundColor: Settings.currentTheme.bodyTextColor, .paragraphStyle: centeredParagraphStyle]))
        
        //Display % sign
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.multiplier = 1
        data.setValueFormatter(DefaultValueFormatter(formatter: numberFormatter))
        data.setValueTextColor(Settings.currentTheme.backgroundColor)
        
        self.pieChartView.data = data
    }
}
