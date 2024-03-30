//
//  GenreListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/06/2021.
//

import SwiftUI

struct GenreListView: View {
    let apiService: APIServiceProtocol

    var body: some View {
        Form {
            Section(content: {
                ForEach(Genre.allCases, id: \.self) { genre in
                    NavigationLink(destination: {
                        BandsByGenreView(apiService: apiService, genre: genre)
                    }, label: {
                        Text(genre.rawValue)
                    })
                }
            }, footer: {
                Text("For genre fine-tuning, use the advanced search")
            })
        }
        .navigationTitle("Bands by genre")
    }
}

struct GenreListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GenreListView(apiService: APIService())
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
