//
//  HomeView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

// swiftlint:disable line_length
struct HomeView: View {
    @EnvironmentObject private var settings: Preferences
    let apiService: APIServiceProtocol

    var body: some View {
        Form {
            NavigationLink(destination: {
                BandView(apiService: apiService,
                         bandUrlString: "https://www.metal-archives.com/bands/Death/141")
            }, label: {
                Text("Death")
            })

            NavigationLink(destination: {
                BandView(apiService: apiService,
                         bandUrlString: "https://www.metal-archives.com/bands/Testament/70")
            }, label: {
                Text("Testament")
            })

            NavigationLink(destination: {
                BandView(apiService: apiService,
                         bandUrlString: "https://www.metal-archives.com/bands/Lamb_of_God/59")
            }, label: {
                Text("Lamb of God")
            })

            NavigationLink(destination: {
                BandView(apiService: apiService,
                         bandUrlString: "https://www.metal-archives.com/bands/Nile/139")
            }, label: {
                Text("Nile")
            })

            NavigationLink(destination: {
                BandView(apiService: apiService,
                         bandUrlString: "https://www.metal-archives.com/bands/Fleshgod_Apocalypse/113185")
            }, label: {
                Text("Fleshgod Apocalypse")
            })

            NavigationLink(destination: {
                BandView(apiService: apiService,
                         bandUrlString: "https://www.metal-archives.com/bands/Cephalic_Destruction/3540495596")
            }, label: {
                Text("Cephalic Destruction")
            })

            NavigationLink(destination: {
                ReleaseView(apiService: apiService,
                            releaseUrlString: "https://www.metal-archives.com/albums/Death/Scream_Bloody_Gore/598")
            }, label: {
                Text("Scream Bloody Gore")
            })

            NavigationLink(destination: {
                ReleaseView(apiService: apiService,
                            releaseUrlString: "https://www.metal-archives.com/albums/Death/Victims_of_Death_-_The_Best_of_Decade_of_Chaos/665400")
            }, label: {
                Text("Victims of Death - The Best of Decade of Chaos")
            })

            NavigationLink(destination: {
                ReleaseView(apiService: apiService,
                            releaseUrlString: "https://www.metal-archives.com/albums/At_Radogost%27s_Gates/Dyau/57765")
            }, label: {
                Text("Dyau")
            })
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(apiService: APIService())
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}
