//
//  MemberStatisticTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Charts

final class MemberStatisticTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var pieChartView: PieChartView!
    @IBOutlet private weak var pieChartViewHeightConstraint: NSLayoutConstraint!

    override func initAppearance() {
        super.initAppearance()
        self.selectionStyle = .none
        self.pieChartView.setup()
        self.pieChartViewHeightConstraint.constant = screenHeight*2/3
    }

    func drawChart(forMemberStatistic memberStatistic: MemberStatistic) {
        let activeEntry = PieChartDataEntry(value: Double(memberStatistic.active), label: "Active members (\(memberStatistic.active.formattedWithSeparator))")
        let inactiveEntry = PieChartDataEntry(value: Double(memberStatistic.inactive), label: "Inactive members (\(memberStatistic.inactive.formattedWithSeparator))")
        
        
        let pieChartDataSet = PieChartDataSet(entries: [activeEntry, inactiveEntry], label: "\(memberStatistic.total.formattedWithSeparator) registered members")
        
        pieChartDataSet.colors = [Settings.currentTheme.activeStatusColor, Settings.currentTheme.closedStatusColor]
        
        let data = PieChartData(dataSet: pieChartDataSet)
        
        
        //Center text
        let centerText = "There is a total of \(memberStatistic.total.formattedWithSeparator) registered members"
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
