//
//  ReviewStatisticTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Charts

final class ReviewStatisticTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var barChartView: BarChartView!
    @IBOutlet private weak var barChartViewHeightConstraint: NSLayoutConstraint!
    
    override func initAppearance() {
        super.initAppearance()
        self.selectionStyle = .none
        self.barChartView.setup()
        self.barChartViewHeightConstraint.constant = screenHeight*1/3
    }

    func drawChart(forReviewStatistic reviewStatistic: ReviewStatistic) {
        let approvedReviewsEntry = BarChartDataEntry(x: Double(0), y: Double(reviewStatistic.approvedReviews))
        let uniqueAlbumsEntry = BarChartDataEntry(x: Double(0.5), y: Double(reviewStatistic.uniqueAlbum))
        
        let approvedReviewsDataSet = BarChartDataSet(values: [approvedReviewsEntry], label: "Approved reviews (\(reviewStatistic.approvedReviews.formattedWithSeparator))")
        approvedReviewsDataSet.colors = [Settings.currentTheme.activeStatusColor]
        approvedReviewsDataSet.valueTextColor = Settings.currentTheme.bodyTextColor
        
        let uniqueAlbumsDataSet = BarChartDataSet(values: [uniqueAlbumsEntry], label: "Unique albums (\(reviewStatistic.uniqueAlbum.formattedWithSeparator))")
        uniqueAlbumsDataSet.colors = [Settings.currentTheme.closedStatusColor]
        uniqueAlbumsDataSet.valueTextColor = Settings.currentTheme.bodyTextColor
        
        let data = BarChartData(dataSets: [approvedReviewsDataSet, uniqueAlbumsDataSet])
        data.barWidth = 0.1
        self.barChartView.data = data
    }
}
