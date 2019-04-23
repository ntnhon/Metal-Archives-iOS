//
//  ArtistStatisticTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Charts

final class ArtistStatisticTableViewCell: BaseTableViewCell, RegisterableCell {
    @IBOutlet private weak var barChartView: BarChartView!
    @IBOutlet private weak var barChartViewHeightConstraint: NSLayoutConstraint!
    
    override func initAppearance() {
        super.initAppearance()
        self.selectionStyle = .none
        self.barChartView.setup()
        self.barChartViewHeightConstraint.constant = screenHeight*1/3
    }
    
    func drawChart(forArtistStatistic artistStatistic: ArtistStatistic) {
        //Total
        let totalEntry = BarChartDataEntry(x: Double(0), y: Double(artistStatistic.total))
        let totalDataSet = BarChartDataSet(entries: [totalEntry], label: "Total artist (\(artistStatistic.total.formattedWithSeparator))")
        totalDataSet.colors = [Settings.currentTheme.changedNameStatusColor, Settings.currentTheme.closedStatusColor]
        totalDataSet.valueTextColor = Settings.currentTheme.bodyTextColor
        
        //Deceased
        let deceasedEntry = BarChartDataEntry(x: Double(0.2), y: Double(artistStatistic.deceased))
        let deceasedDataSet = BarChartDataSet(entries: [deceasedEntry], label: "Deceased artist (\(artistStatistic.deceased.formattedWithSeparator))")
        deceasedDataSet.colors = [Settings.currentTheme.closedStatusColor, Settings.currentTheme.closedStatusColor]
        deceasedDataSet.valueTextColor = Settings.currentTheme.bodyTextColor
        
        
        //Still playing
        let stillPlayingEntry = BarChartDataEntry(x: Double(0.4), y: Double(artistStatistic.stillPlaying))
        
        let stillPlayingDataSet = BarChartDataSet(entries: [stillPlayingEntry], label: "Still playing (\(artistStatistic.stillPlaying.formattedWithSeparator))")
        stillPlayingDataSet.colors = [Settings.currentTheme.activeStatusColor]
        stillPlayingDataSet.valueTextColor = Settings.currentTheme.bodyTextColor
    
        
        //Quit playing
        let quitPlayingEntry = BarChartDataEntry(x: Double(0.6), y: Double(artistStatistic.quitPlaying))
        let quitPlayingDataSet = BarChartDataSet(entries: [quitPlayingEntry], label: "Quit playing (\(artistStatistic.quitPlaying.formattedWithSeparator))")
        quitPlayingDataSet.colors = [.gray]
        quitPlayingDataSet.valueTextColor = Settings.currentTheme.bodyTextColor
        
        //Female
        let femaleEntry = BarChartDataEntry(x: Double(0.8), y: Double(artistStatistic.female))
        let femaleDataSet = BarChartDataSet(entries: [femaleEntry], label: "Female (\(artistStatistic.female.formattedWithSeparator))")
        femaleDataSet.colors = [.magenta]
        femaleDataSet.valueTextColor = Settings.currentTheme.bodyTextColor
        
        //Male
        let maleEntry = BarChartDataEntry(x: Double(1), y: Double(artistStatistic.male))
        let maleDataSet = BarChartDataSet(entries: [maleEntry], label: "Male (\(artistStatistic.male.formattedWithSeparator))")
        maleDataSet.colors = [.cyan]
        maleDataSet.valueTextColor = Settings.currentTheme.bodyTextColor
        
        //Unknown
        let unknownEntry = BarChartDataEntry(x: Double(1.2), y: Double(artistStatistic.unknownOrEntities))
        let unknownDataSet = BarChartDataSet(entries: [unknownEntry], label: "Unknown or entities (such as orchestras) (\(artistStatistic.unknownOrEntities.formattedWithSeparator))")
        unknownDataSet.colors = [.yellow]
        unknownDataSet.valueTextColor = Settings.currentTheme.bodyTextColor
        
        let data = BarChartData(dataSets: [totalDataSet, deceasedDataSet, stillPlayingDataSet, quitPlayingDataSet, femaleDataSet, maleDataSet, unknownDataSet])
        data.barWidth = 0.1
        self.barChartView.data = data
    }
}
