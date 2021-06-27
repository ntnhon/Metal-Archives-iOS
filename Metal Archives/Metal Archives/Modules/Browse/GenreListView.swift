//
//  GenreListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/06/2021.
//

import SwiftUI

struct GenreListView: View {
    var body: some View {
        Form {
            ForEach(Genre.allCases, id: \.self) { genre in
                NavigationLink(destination: Text(genre.rawValue)) {
                    Text(genre.rawValue)
                }
            }
        }
        .navigationTitle("Bands by genre")
    }
}

struct GenreListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GenreListView()
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
