//
//  WhatsNewView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/04/2024.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var preferences: Preferences
    let version: AppVersion
    let showVersion: Bool

    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                Text(showVersion ?
                    "Version \(version.name)" :
                    "What's New in Metal Archives")
                    .font(.title.bold())
                    .padding(.vertical)
                ForEach(version.newFeatures) {
                    cell(for: $0)
                        .padding(.vertical)
                }
            }

            if !showVersion {
                Button(action: dismiss.callAsFunction) {
                    Text("Continue")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(preferences.theme.primaryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding([.horizontal, .bottom])
        .tint(preferences.theme.primaryColor)
        .if(!showVersion) { view in
            NavigationView {
                view
            }
            .navigationViewStyle(.stack)
        }
    }

    func cell(for feature: NewFeature) -> some View {
        HStack {
            Image(systemName: feature.systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 48)
                .foregroundColor(preferences.theme.primaryColor)
            VStack(alignment: .leading) {
                Text(feature.title)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(feature.description)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    WhatsNewView(version: .fiveDotOneDotZero, showVersion: .random())
        .environmentObject(Preferences())
        .preferredColorScheme(.dark)
}
