//
//  HomeSectionOrderView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

struct HomeSectionOrderView: View {
    @EnvironmentObject private var preferences: Preferences

    var body: some View {
        Form {
            Section(footer: Text("Hold & drag ≡ icon to change order")) {
                ForEach(preferences.homeSectionOrder, id: \.self) {
                    Text($0.description)
                }
                .onMove(perform: handleMove)
            }
        }
        .navigationTitle("Home section order")
        .environment(\.editMode, .constant(.active))
    }

    private func handleMove(from source: IndexSet, to destination: Int) {
        preferences.$homeSectionOrder.wrappedValue.move(fromOffsets: source, toOffset: destination)
        preferences.objectWillChange.send()
    }
}

struct HomeSectionOrderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeSectionOrderView()
                .environmentObject(Preferences())
        }
    }
}
