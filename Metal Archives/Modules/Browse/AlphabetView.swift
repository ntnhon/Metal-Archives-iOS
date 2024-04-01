//
//  AlphabetView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/06/2021.
//

import SwiftUI

enum AlphabetMode {
    case bands, labels

    var navigationTitle: String {
        switch self {
        case .bands:
            "Bands by alphabet"
        case .labels:
            "Labels by alphabet"
        }
    }
}

private let kFooterNote = """
For numbers, select #.
For non-Latin alphabets or for symbols, select ~.
Note: leading "The __" are ignored (e.g. "The Chasm" appears under C, not T)
"""

struct AlphabetView: View {
    let mode: AlphabetMode

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                ForEach(Letter.allCases, id: \.self) { letter in
                    NavigationLink(destination: {
                        switch mode {
                        case .bands:
                            BandsByAlphabetView(letter: letter)
                        case .labels:
                            LabelsByAlphabetView(letter: letter)
                        }
                    }, label: {
                        if case .labels = mode, letter == .tilde {
                            EmptyView()
                        } else {
                            Text(letter.description)
                                .font(.title)
                                .fontWeight(.medium)
                                .frame(width: 50, height: 50)
                                .background(Color.secondary
                                    .opacity(0.15)
                                    .clipShape(RoundedRectangle(cornerRadius: 2))
                                )
                        }
                    })
                    .buttonStyle(.plain)
                }
            }
            .padding()

            Text(kFooterNote)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .navigationBarTitle(mode.navigationTitle, displayMode: .inline)
    }
}

#Preview {
    NavigationView {
        AlphabetView(mode: .bands)
    }
    .environment(\.colorScheme, .dark)
    .environmentObject(Preferences())
}
