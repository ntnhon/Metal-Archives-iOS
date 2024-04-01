//
//  HomeSectionOrderView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

struct HomeSectionOrderView: View {
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.editMode) private var editMode

    var body: some View {
        Form {
            Section(content: {
                ForEach(preferences.homeSectionOrder, id: \.self) {
                    Text($0.description)
                }
                .onMove(perform: handleMove)
            }, footer: {
                if editMode?.wrappedValue.isEditing == true {
                    Text("Hold & drag ≡ icon to change order")
                        .animation(.default, value: editMode?.wrappedValue)
                }
            })
        }
        .navigationBarTitle("Home section order", displayMode: .inline)
        .toolbar { EditButton() }
        .onAppear {
            editMode?.wrappedValue = .active
        }
    }

    private func handleMove(from source: IndexSet, to destination: Int) {
        preferences.$homeSectionOrder.wrappedValue.move(fromOffsets: source,
                                                        toOffset: destination)
    }
}

#Preview {
    NavigationView {
        HomeSectionOrderView()
    }
    .environment(\.colorScheme, .dark)
    .environmentObject(Preferences())
}
