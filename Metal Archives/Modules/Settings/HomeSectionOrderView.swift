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
    @Environment(\.dismiss) private var dismiss
    @State private var tempOrder: [HomeSection] = []

    var body: some View {
        Form {
            Section(content: {
                ForEach(preferences.homeSectionOrder, id: \.self) {
                    Text($0.description)
                }
                .onMove { src, dest in
                    tempOrder.move(fromOffsets: src, toOffset: dest)
                }
            }, footer: {
                if editMode?.wrappedValue == .active {
                    Text("Hold & drag ≡ icon to change order")
                        .animation(.default, value: editMode?.wrappedValue)
                }
            })
        }
        .navigationBarTitle("Home section order")
        .onAppear {
            tempOrder = preferences.homeSectionOrder
        }
        .toolbar {
            if editMode?.wrappedValue == .inactive {
                Button("Edit", systemImage: "square.and.pencil") {
                    withAnimation {
                        editMode?.wrappedValue = .active
                    }
                }
            } else if #available(iOS 26, macOS 26, *) {
                doneButton
                    .buttonStyle(.glassProminent)
            } else {
                doneButton
            }
        }
    }
}

private extension HomeSectionOrderView {
    var doneButton: some View {
        Button("Done", systemImage: "checkmark") {
            withAnimation {
                editMode?.wrappedValue = .inactive
                preferences.homeSectionOrder = tempOrder
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationView {
        HomeSectionOrderView()
    }
    .environment(\.colorScheme, .dark)
    .environmentObject(Preferences())
}
