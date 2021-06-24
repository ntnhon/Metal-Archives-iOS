//
//  ReleaseFormatListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/06/2021.
//

import SwiftUI

struct ReleaseFormatListView: View {
    @ObservedObject var releaseFormatSet: ReleaseFormatSet
    @State private var navigationTitle = "Any format"

    var body: some View {
        List {
            ForEach(ReleaseFormat.allCases, id: \.self) { format in
                HStack {
                    Button(action: {
                        handleSelection(format)
                    }, label: {
                        Text(format.rawValue)
                    })
                    .foregroundColor(.primary)

                    if releaseFormatSet.formats.contains(format) {
                        Spacer()

                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle(navigationTitle, displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    releaseFormatSet.formats.removeAll()
                                    updateNavigationTitle()
                                }, label: {
                                    Text("Deselect all")
                                }))
        .onAppear {
            updateNavigationTitle()
        }
    }

    private func handleSelection(_ format: ReleaseFormat) {
        if releaseFormatSet.formats.contains(format) {
            releaseFormatSet.formats.removeAll { $0 == format }
        } else {
            releaseFormatSet.formats.append(format)
        }
        if releaseFormatSet.formats.count == ReleaseFormat.allCases.count {
            releaseFormatSet.formats.removeAll()
        }
        updateNavigationTitle()
    }

    private func updateNavigationTitle() {
        if releaseFormatSet.formats.isEmpty {
            navigationTitle = "Any format"
        } else if releaseFormatSet.formats.count == 1 {
            navigationTitle = "1 format selected"
        } else {
            navigationTitle = "\(releaseFormatSet.formats.count ) formats selected"
        }
    }
}

struct ReleaseFormatListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReleaseFormatListView(releaseFormatSet: .init())
        }
    }
}
