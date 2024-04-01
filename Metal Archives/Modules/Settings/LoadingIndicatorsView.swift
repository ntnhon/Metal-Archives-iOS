//
//  LoadingIndicatorsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/04/2024.
//

import SwiftfulLoadingIndicators
import SwiftUI

private typealias Animation = LoadingIndicator.LoadingAnimation

struct LoadingIndicatorsView: View {
    @EnvironmentObject private var preferences: Preferences
    private let columns: [GridItem] =
        [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(Animation.allCases, id: \.self) {
                    preview(for: $0)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .animation(.default, value: preferences.loadingAnimation)
        .navigationTitle("Loading animation")
    }
}

private extension LoadingIndicatorsView {
    @ViewBuilder
    func preview(for animation: Animation) -> some View {
        let selected = preferences.loadingAnimation == animation
        let selectedBackground = preferences.theme.secondaryColor.opacity(0.45)
        VStack(alignment: .center) {
            LoadingIndicator(animation: animation, color: .secondary)
            Text(animation.title)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(selected ? selectedBackground : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
        .onTapGesture {
            preferences.loadingAnimation = animation
        }
    }
}

#Preview {
    NavigationView {
        LoadingIndicatorsView()
            .environmentObject(Preferences())
            .preferredColorScheme(.dark)
    }
}
