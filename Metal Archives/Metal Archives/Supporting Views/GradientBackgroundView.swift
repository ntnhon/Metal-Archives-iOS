//
//  GradientBackgroundView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 02/11/2022.
//

import SwiftUI

struct GradientBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: .init(colors: [Color(.systemBackground),
                                     Color(.systemBackground.withAlphaComponent(0.9)),
                                     Color(.systemBackground.withAlphaComponent(0.8)),
                                     Color(.systemBackground.withAlphaComponent(0.7)),
                                     Color(.systemBackground.withAlphaComponent(0.6)),
                                     Color(.systemBackground.withAlphaComponent(0.5)),
                                     Color(.systemBackground.withAlphaComponent(0.4)),
                                     Color(.systemBackground.withAlphaComponent(0.3)),
                                     Color(.systemBackground.withAlphaComponent(0.2)),
                                     Color(.systemBackground.withAlphaComponent(0.1)),
                                     Color(.systemBackground.withAlphaComponent(0.05)),
                                     Color(.systemBackground.withAlphaComponent(0.025)),
                                     Color.clear]),
            startPoint: .bottom,
            endPoint: .top)
    }
}
