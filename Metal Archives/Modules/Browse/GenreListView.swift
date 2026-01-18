//
//  GenreListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/06/2021.
//

import SwiftUI

struct GenreListView: View {
    @Binding var path: NavigationPath

    var body: some View {
        Form {
            Section(content: {
                ForEach(Genre.allCases, id: \.self) { genre in
                    NavigationLink(destination: {
                        BandsByGenreView(genre: genre, path: $path)
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

#Preview {
    NavigationView {
        GenreListView(path: .constant(.init()))
    }
    .environment(\.colorScheme, .dark)
    .environmentObject(Preferences())
}
