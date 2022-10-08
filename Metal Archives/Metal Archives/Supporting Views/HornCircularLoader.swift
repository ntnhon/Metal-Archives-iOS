//
//  HornCircularLoader.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/10/2022.
//

import SwiftUI

struct HornCircularLoader: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Text("🤘")
                .font(.title)
                .scaleEffect(isAnimating ? 0.65 : 1.2)
                .animation(.linear(duration: 0.5).repeatForever(),
                           value: isAnimating)

            Circle()
                .stroke(Color(uiColor: .systemGray6),
                        style: .init(lineWidth: 2))

            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(preferences.theme.primaryColor,
                        style: .init(lineWidth: 4,
                                     lineCap: .round))
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false),
                           value: isAnimating)
        }
        .frame(width: 50, height: 50)
        .onAppear {
            isAnimating = true
        }
    }
}

struct HornCircularLoader_Previews: PreviewProvider {
    static var previews: some View {
        HornCircularLoader()
            .environmentObject(Preferences())
    }
}
