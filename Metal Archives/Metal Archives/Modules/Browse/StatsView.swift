//
//  StatsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Charts
import SwiftUI

@available(iOS 16, *)
struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService))
    }

    var body: some View {
        ZStack {
            switch viewModel.statsFetchable {
            case .fetching:
                HornCircularLoader()
                    .navigationBarTitleDisplayMode(.inline)

            case .fetched(let stats):
                StatsContentView(stats: stats)

            case .error(let error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        Task {
                            await viewModel.refreshStats(force: true)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.refreshStats(force: false)
        }
    }
}

@available(iOS 16, *)
private struct StatsContentView: View {
    let stats: Stats
    let bandStatsValues: [ChartValues]
    let reviewStatsValues: [ChartValues]
    let labelStatsValues: [ChartValues]
    let artistStatusStatsValues: [ChartValues]
    let artistGenderStatsValues: [ChartValues]
    let memberStatsValues: [ChartValues]
    let releaseStatsValues: [ChartValues]

    init(stats: Stats) {
        self.stats = stats
        bandStatsValues = [
            .init(title: "Total", value: stats.bandStats.total, color: .primary),
            .init(title: "Active", value: stats.bandStats.active, color: .green),
            .init(title: "On hold", value: stats.bandStats.onHold, color: .yellow),
            .init(title: "Split up", value: stats.bandStats.splitUp, color: .red),
            .init(title: "Changed name", value: stats.bandStats.changedName, color: .blue),
            .init(title: "Unknown", value: stats.bandStats.unknown, color: .orange)
        ]

        reviewStatsValues = [
            .init(title: "Total", value: stats.reviewStats.total, color: .primary),
            .init(title: "Unique albums", value: stats.reviewStats.uniqueAlbums, color: .blue)
        ]

        labelStatsValues = [
            .init(title: "Total", value: stats.labelStats.total, color: .primary),
            .init(title: "Active", value: stats.labelStats.active, color: .green),
            .init(title: "Closed", value: stats.labelStats.closed, color: .red),
            .init(title: "Changed name", value: stats.labelStats.changedName, color: .blue),
            .init(title: "Unknown", value: stats.labelStats.unknown, color: .orange)
        ]

        artistStatusStatsValues = [
            .init(title: "Total", value: stats.artistStats.total, color: .primary),
            .init(title: "Still playing", value: stats.artistStats.stillPlaying, color: .green),
            .init(title: "Quit playing", value: stats.artistStats.quitPlaying, color: .red),
            .init(title: "Deceased", value: stats.artistStats.deceased, color: .purple)
        ]

        artistGenderStatsValues = [
            .init(title: "Total", value: stats.artistStats.total, color: .primary),
            .init(title: "Female", value: stats.artistStats.female, color: .pink),
            .init(title: "Male", value: stats.artistStats.male, color: .blue),
            .init(title: "Non-binary", value: stats.artistStats.nonBinary, color: .gray),
            .init(title: "Non-gendered", value: stats.artistStats.nonGendered, color: .yellow),
            .init(title: "Unknown", value: stats.artistStats.unknown, color: .orange)
        ]

        memberStatsValues = [
            .init(title: "Total", value: stats.memberStats.total, color: .primary),
            .init(title: "Active", value: stats.memberStats.active, color: .green),
            .init(title: "Inactive", value: stats.memberStats.inactive, color: .red)
        ]

        releaseStatsValues = [
            .init(title: "Albums", value: stats.releaseStats.albums, color: .blue),
            .init(title: "Songs", value: stats.releaseStats.songs, color: .green)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                StatsChartView(title: "Band stats", values: bandStatsValues)
                StatsChartView(title: "Review stats", values: reviewStatsValues)
                StatsChartView(title: "Label stats", values: labelStatsValues)
                StatsChartView(title: "Artist status stats", values: artistStatusStatsValues)
                StatsChartView(title: "Artist gender stats", values: artistGenderStatsValues)
                StatsChartView(title: "Member stats", values: memberStatsValues)
                StatsChartView(title: "Release stats", values: releaseStatsValues)
            }
        }
        .navigationTitle(stats.timestamp)
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct ChartValues: Identifiable {
    var id: String { title }
    let title: String
    let value: Int
    let color: Color
}

@available(iOS 16, *)
private struct StatsChartView: View {
    let title: String
    let values: [ChartValues]

    var body: some View {
        GroupBox(title) {
            Chart(values) { value in
                BarMark(x: .value("Title", value.title), y: .value("Value", value.value))
                    .foregroundStyle(value.color)
                    .annotation(position: .top, spacing: 8) {
                        Text("\(value.value)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
            }
        }
        .frame(minHeight: 250)
    }
}
