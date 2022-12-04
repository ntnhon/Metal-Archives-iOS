//
//  LatestAdditionsSection.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import SwiftUI

enum AdditionType: String, CaseIterable {
    case bands = "Bands"
    case labels = "Labels"
    case artists = "Artists"
}

struct LatestAdditionsSection: View {
    @State private var selectedAdditionType = AdditionType.bands
    var body: some View {
        VStack {
            HStack {
                Text("Latest additions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                NavigationLink(destination: { Text("All") },
                               label: { Text("See All") })
            }
            .padding(.horizontal)

            Picker("", selection: $selectedAdditionType) {
                ForEach(AdditionType.allCases, id: \.rawValue) { type in
                    Text(type.rawValue)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ForEach(0..<5, id: \.self) { index in
                Button(action: {
                    print("Select \(index)")
                }, label: {
                    Text("#\(index)")
                })
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
