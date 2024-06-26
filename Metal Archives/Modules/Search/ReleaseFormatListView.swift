//
//  ReleaseFormatListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/06/2021.
//

import SwiftUI

struct ReleaseFormatListView: View {
    @ObservedObject var releaseFormatSet: ReleaseFormatSet

    var body: some View {
        Form {
            Section(content: {
                ForEach(ReleaseFormat.allCases, id: \.self) { format in
                    HStack {
                        Text(format.rawValue)
                        Spacer()
                        if releaseFormatSet.isSelected(format) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { releaseFormatSet.select(format) }
                }
            }, header: {
                Text("Release formats")
            })
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(releaseFormatSet.title)
                .fontWeight(.bold)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if !releaseFormatSet.noChoice {
                Button(action: releaseFormatSet.deselectAll) {
                    Text("Deselect all")
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ReleaseFormatListView(releaseFormatSet: .init())
    }
    .environment(\.colorScheme, .dark)
    .environmentObject(Preferences())
}
