//
//  BandStatusListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/06/2021.
//

import SwiftUI

struct BandStatusListView: View {
    @ObservedObject var bandStatusSet: BandStatusSet

    var body: some View {
        Form {
            ForEach(BandStatus.allCases, id: \.self) { status in
                HStack {
                    Text(status.rawValue)
                    Spacer()

                    if bandStatusSet.isSelected(status) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { bandStatusSet.select(status) }
            }
        }
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(bandStatusSet.title)
                .fontWeight(.bold)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if !bandStatusSet.noChoice {
                Button(action: bandStatusSet.deselectAll) {
                    Text("Deselect all")
                }
            }
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
