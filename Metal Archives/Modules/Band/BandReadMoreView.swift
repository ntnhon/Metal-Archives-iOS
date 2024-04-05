//
//  BandReadMoreView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/07/2021.
//

import Combine
import SwiftUI

struct BandReadMoreView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var showingSheet = false
    let band: Band
    let readMore: String

    var body: some View {
        Text(readMore)
            .font(.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(6)
            .padding()
            .onTapGesture {
                showingSheet.toggle()
            }
            .sheet(isPresented: $showingSheet) {
                NavigationView {
                    ScrollView {
                        Text(readMore)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)
                    }
                    .navigationTitle(band.name)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showingSheet.toggle()
                            }, label: {
                                Image(systemName: "xmark")
                            })
                        }
                    }
                }
                .tint(preferences.theme.primaryColor)
                .preferredColorScheme(.dark)
            }
    }
}
