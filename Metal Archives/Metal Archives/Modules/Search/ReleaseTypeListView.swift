//
//  ReleaseTypeListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/06/2021.
//

import SwiftUI

struct ReleaseTypeListView: View {
    @ObservedObject var releaseTypeSet: ReleaseTypeSet

    var body: some View {
        Form {
            ForEach(ReleaseType.allCases, id: \.self) { type in
                HStack {
                    Text(type.description)
                    Spacer()
                    if releaseTypeSet.types.contains(type) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { releaseTypeSet.select(type: type) }
            }
        }
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(releaseTypeSet.navigationTitle)
                .fontWeight(.bold)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if !releaseTypeSet.types.isEmpty {
                Button(action: releaseTypeSet.removeAll) {
                    Text("Deselect all")
                }
            }
        }
    }
}

struct ReleaseTypeListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReleaseTypeListView(releaseTypeSet: .init())
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
