//
//  HomeView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

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
                ReleaseView(apiService: apiService,
                            releaseUrlString: "https://www.metal-archives.com/albums/Death/Scream_Bloody_Gore/598")
            }, label: {
                Text("Scream Bloody Gore")
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
