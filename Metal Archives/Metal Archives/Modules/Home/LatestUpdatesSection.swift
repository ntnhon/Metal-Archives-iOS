//
//  LatestUpdatesSection.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import SwiftUI

typealias UpdateType = AdditionType

struct LatestUpdatesSection: View {
    @State private var selectedUpdateType = UpdateType.bands
    var body: some View {
        VStack {
            HStack {
                Text("Latest updates")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                NavigationLink(destination: { Text("All") },
                               label: { Text("See All") })
            }
            .padding(.horizontal)

            Picker("", selection: $selectedUpdateType) {
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
