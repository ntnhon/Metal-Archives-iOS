//
//  ReleaseStatisticTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Charts

final class ReleaseStatisticTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var barChartView: BarChartView!
    @IBOutlet private weak var barChartViewHeightConstraint: NSLayoutConstraint!
    
    override func initAppearance() {
        super.initAppearance()
        self.selectionStyle = .none
        self.barChartView.setup()
        self.barChartViewHeightConstraint.constant = screenHeight*1/3
    }

    func drawChart(forReleaseStatistic releaseStatistic: ReleaseStatistic) {
        let albumsEntry = BarChartDataEntry(x: Double(0), y: Double(releaseStatistic.albums))
        let songsEntry = BarChartDataEntry(x: Double(0.5), y: Double(releaseStatistic.songs))
        
        let albumsDataSet = BarChartDataSet(entries: [albumsEntry], label: "Albums (\(releaseStatistic.albums.formattedWithSeparator))")
        albumsDataSet.colors = [Settings.currentTheme.activeStatusColor]
        albumsDataSet.valueTextColor = Settings.currentTheme.bodyTextColor
        
        let songsDataSet = BarChartDataSet(entries: [songsEntry], label: "Songs (\(releaseStatistic.songs.formattedWithSeparator))")
        songsDataSet.colors = [Settings.currentTheme.closedStatusColor]
        songsDataSet.valueTextColor = Settings.currentTheme.bodyTextColor
        
        let data = BarChartData(dataSets: [albumsDataSet, songsDataSet])
        data.barWidth = 0.1
        self.barChartView.data = data
    }
}
