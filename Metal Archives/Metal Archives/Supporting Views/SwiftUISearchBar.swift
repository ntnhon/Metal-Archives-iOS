//
//  SwiftUISearchBar.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 11/11/2022.
//

import SwiftUI

struct SwiftUISearchBar: UIViewRepresentable {
    @Binding var term: String
    let placeholder: String
    let onSubmit: () -> Void

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.delegate = context.coordinator
        searchBar.backgroundImage = .init() // clear top & bottom lines
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.placeholder = placeholder
    }

    func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }

    final class Coordinator: NSObject, UISearchBarDelegate {
        let parent: SwiftUISearchBar

        init(parent: SwiftUISearchBar) {
            self.parent = parent
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.term = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            parent.onSubmit()
        }
    }
}
