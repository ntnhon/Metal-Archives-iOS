//
//  HomeView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var settings: Settings

    var body: some View {
        Form {
            Section {
                ForEach(settings.homeSectionOrder, id: \.self) {
                    Text($0.description)
                }
            }

            Section {
                Text("Thumbnail \(settings.showThumbnails.description)")
            }

            Section {
                Text("Haptic \(settings.useHaptic.description)")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(Settings())
    }
}
