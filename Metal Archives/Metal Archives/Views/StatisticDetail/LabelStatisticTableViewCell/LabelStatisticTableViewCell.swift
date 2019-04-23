//
//  LabelStatisticTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Charts

final class LabelStatisticTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var pieChartView: PieChartView!
    @IBOutlet private weak var pieChartViewHeightConstraint: NSLayoutConstraint!
    
    override func initAppearance() {
        super.initAppearance()
        self.selectionStyle = .none
        self.pieChartView.setup()
        self.pieChartViewHeightConstraint.constant = screenHeight*2/3
    }
    
    func drawChart(forLabelStatistic labelStatistic: LabelStatistic) {
        let activeEntry = PieChartDataEntry(value: Double(labelStatistic.active.count), label: "\(labelStatistic.active.description) (\(labelStatistic.active.count.formattedWithSeparator))")
        let closedEntry = PieChartDataEntry(value: Double(labelStatistic.closed.count), label: "\(labelStatistic.closed.description) (\(labelStatistic.closed.count.formattedWithSeparator))")
        let changedNameEntry = PieChartDataEntry(value: Double(labelStatistic.changedName.count), label: "\(labelStatistic.changedName.description) (\(labelStatistic.changedName.count.formattedWithSeparator))")
        let unknownEntry = PieChartDataEntry(value: Double(labelStatistic.unknown.count), label: "\(labelStatistic.unknown.description) (\(labelStatistic.unknown.count.formattedWithSeparator))")
        
        
        let pieChartDataSet = PieChartDataSet(entries: [activeEntry, closedEntry, changedNameEntry, unknownEntry], label: "\(labelStatistic.total.formattedWithSeparator) labels")
        
        pieChartDataSet.colors = [labelStatistic.active.color, labelStatistic.closed.color, labelStatistic.changedName.color, labelStatistic.unknown.color]
        
        let data = PieChartData(dataSet: pieChartDataSet)
        
        
        //Center text
        let centerText = "There is a total of \(labelStatistic.total.formattedWithSeparator) labels"
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
