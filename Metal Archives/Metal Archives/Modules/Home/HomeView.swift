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

            NavigationLink(
                destination: BandView(bandUrlString: "https://www.metal-archives.com/bands/Testament/70")) {
                Text("Testament")
            }

            NavigationLink(
                destination: BandView(bandUrlString: "https://www.metal-archives.com/bands/Lamb_of_God/59")) {
                Text("Lamb of God")
            }

            NavigationLink(
                destination: BandView(bandUrlString: "https://www.metal-archives.com/bands/Nile/139")) {
                Text("Nile")
            }

            NavigationLink(
                // swiftlint:disable:next line_length
                destination: BandView(bandUrlString: "https://www.metal-archives.com/bands/Fleshgod_Apocalypse/113185")) {
                Text("Fleshgod Apocalypse")
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
