//
//  HorizontalTabs.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 10/10/2022.
//

import SwiftUI

class HorizontalTabsDatasource: ObservableObject {
    func numberOfTabs() -> Int { 0 }
    func titleForTab(index _: Int) -> String { "" }
    func normalSystemIconNameForTab(index _: Int) -> String { "" }
    func selectedSystemIconNameForTab(index _: Int) -> String { "" }
    func isSelectedTab(index _: Int) -> Bool { false }
    func onSelectTab(index _: Int) {}
}

struct HorizontalTabs: View {
    @EnvironmentObject private var preferences: Preferences
    @ObservedObject var datasource: HorizontalTabsDatasource

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollViewReader in
                HStack(spacing: 0) {
                    ForEach(0 ..< datasource.numberOfTabs(), id: \.self) { index in
                        tab(for: index, proxy: scrollViewReader)
                    }
                }
                .padding(.leading)
            }
        }
    }

    private func tab(for index: Int, proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 0) {
            Label(title: {
                Text(datasource.titleForTab(index: index))
                    .fontWeight(.bold)
                    .font(.headline)
            }, icon: {
                Image(systemName: datasource.isSelectedTab(index: index) ?
                    datasource.selectedSystemIconNameForTab(index: index) :
                    datasource.normalSystemIconNameForTab(index: index))
            })
            .foregroundColor(datasource.isSelectedTab(index: index) ? preferences.theme.primaryColor : .secondary)
            Color(index != datasource.numberOfTabs() - 1 ? .separator : .clear)
                .frame(width: 1, height: 16)
                .padding(.horizontal)
        }
        .id(index)
        .contentShape(Rectangle())
        .onTapGesture {
            datasource.onSelectTab(index: index)
            withAnimation {
                proxy.scrollTo(index, anchor: .center)
            }
        }
    }
}

#Preview {
    HorizontalTabs(datasource: BandTabsDatasource())
        .environmentObject(Preferences())
}
