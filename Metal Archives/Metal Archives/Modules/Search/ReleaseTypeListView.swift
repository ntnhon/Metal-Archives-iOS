//
//  ReleaseTypeListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/06/2021.
//

import SwiftUI

struct ReleaseTypeListView: View {
    @ObservedObject var releaseTypeSet: ReleaseTypeSet
    @State private var navigationTitle = "Any type"

    var body: some View {
        List {
            ForEach(ReleaseType.allCases, id: \.self) { type in
                HStack {
                    Button(action: {
                        handleSelection(type)
                    }, label: {
                        Text(type.description)
                    })
                    .foregroundColor(.primary)

                    if releaseTypeSet.types.contains(type) {
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
                                    releaseTypeSet.types.removeAll()
                                    updateNavigationTitle()
                                }, label: {
                                    Text("Deselect all")
                                }))
        .onAppear {
            updateNavigationTitle()
        }
    }

    private func handleSelection(_ type: ReleaseType) {
        if releaseTypeSet.types.contains(type) {
            releaseTypeSet.types.removeAll { $0 == type }
        } else {
            releaseTypeSet.types.append(type)
        }
        if releaseTypeSet.types.count == ReleaseType.allCases.count {
            releaseTypeSet.types.removeAll()
        }
        updateNavigationTitle()
    }

    private func updateNavigationTitle() {
        if releaseTypeSet.types.isEmpty {
            navigationTitle = "Any type"
        } else if releaseTypeSet.types.count == 1 {
            navigationTitle = "1 type selected"
        } else {
            navigationTitle = "\(releaseTypeSet.types.count ) types selected"
        }
    }
}

struct ReleaseTypeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReleaseTypeListView(releaseTypeSet: .init())
        }
    }
}
