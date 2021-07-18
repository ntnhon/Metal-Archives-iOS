//
//  HomeView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var settings: Preferences

    var body: some View {
        Form {
            NavigationLink(
                destination: BandView(bandUrlString: "https://www.metal-archives.com/bands/Death/141")) {
                Text("Death")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}
