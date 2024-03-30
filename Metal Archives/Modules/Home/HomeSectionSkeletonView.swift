//
//  HomeSectionSkeletonView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 07/12/2022.
//

import SnapToScroll
import SwiftUI

struct HomeSectionSkeletonView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<2) { _ in
                    VStack(alignment: .leading, spacing: 0) {
                        HomeEntryView()
                            .frame(maxWidth: .infinity)
                        HomeEntryView()
                            .frame(maxWidth: .infinity)
                        HomeEntryView()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.leading)
        }
        .frame(height: HomeSettings.pageHeight)
        .disabled(true)
    }
}

struct HomeEntryView: View {
    var body: some View {
        HStack {
            AnimatingGrayGradient()
                .frame(width: 64, height: 64)
                .clipShape(Rectangle())

            VStack(alignment: .leading) {
                Spacer()
                AnimatingGrayGradient()
                    .frame(width: 220, height: 10)
                    .clipShape(Capsule())
                AnimatingGrayGradient()
                    .frame(width: 200, height: 10)
                    .clipShape(Capsule())
                AnimatingGrayGradient()
                    .frame(width: 180, height: 10)
                    .clipShape(Capsule())
                AnimatingGrayGradient()
                    .frame(width: 160, height: 10)
                    .clipShape(Capsule())
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct AnimatingGrayGradient: View {
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            Color(.systemGray6)
            LinearGradient(colors: [.clear, Color(.systemGray5), .clear],
                           startPoint: .leading,
                           endPoint: .trailing)
            .offset(x: animateGradient ? 300 : -200)
            .frame(width: 200)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                animateGradient.toggle()
            }
        }
    }
}
