//
//  BandStatusListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/06/2021.
//

import SwiftUI

struct BandStatusListView: View {
    @ObservedObject var bandStatusSet: BandStatusSet
    @State private var navigationTitle = "Any status"

    var body: some View {
        List {
            ForEach(BandStatus.allCases, id: \.self) { status in
                HStack {
                    Button(action: {
                        handleSelection(status)
                    }, label: {
                        Text(status.rawValue)
                    })
                    .foregroundColor(.primary)

                    if bandStatusSet.status.contains(status) {
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
                                    bandStatusSet.status.removeAll()
                                    updateNavigationTitle()
                                }, label: {
                                    Text("Deselect all")
                                }))
        .onAppear {
            updateNavigationTitle()
        }
    }

    private func handleSelection(_ status: BandStatus) {
        if bandStatusSet.status.contains(status) {
            bandStatusSet.status.removeAll { $0 == status }
        } else {
            bandStatusSet.status.append(status)
        }
        if bandStatusSet.status.count == BandStatus.allCases.count {
            bandStatusSet.status.removeAll()
        }
        updateNavigationTitle()
    }

    private func updateNavigationTitle() {
        if bandStatusSet.status.isEmpty {
            navigationTitle = "Any status"
        } else {
            navigationTitle = "\(bandStatusSet.status.count ) status selected"
        }
    }
}

struct BandStatusListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandStatusListView(bandStatusSet: .init())
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
