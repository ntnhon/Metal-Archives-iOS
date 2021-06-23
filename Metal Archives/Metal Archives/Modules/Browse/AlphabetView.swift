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
        case .bands: return "Bands by alphabet"
        case .labels: return "Labels by alphabet"
        }
    }
}

private let kFooterNote = """
    For numbers, select #.
    For non-Latin alphabets or for symbols, select ~.
    Note: leading "The __" are ignored (e.g. "The Chasm" appears under C, not T)
    """

struct AlphabetView: View {
    @State private var showResults = false
    @State private var seletedLetter: Letter = .a
    let mode: AlphabetMode

    var body: some View {
        ScrollView {
            NavigationLink(destination: Text(seletedLetter.description), isActive: $showResults) {
                EmptyView()
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                ForEach(Letter.allCases, id: \.self) { letter in
                    Text(letter.description)
                        .font(.title)
                        .fontWeight(.medium)
                        .frame(width: 50, height: 50)
                        .background(Color.secondary
                                        .opacity(0.15)
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                        )
                        .onTapGesture {
                            seletedLetter = letter
                            showResults = true
                        }
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

struct AlphabetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlphabetView(mode: .bands)
        }
    }
}
