//
//  DiscographyView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/07/2021.
//

import SwiftUI

struct DiscographyView: View {
    @EnvironmentObject private var preferences: Preferences
    @StateObject private var viewModel: DiscographyViewModel
    @State private var selectedMode: DiscographyMode = .complete
    @State private var releaseYearOrder: Order

    init(discography: Discography, releaseYearOrder: Order) {
        _viewModel = StateObject(wrappedValue: .init(discography: discography))
        _releaseYearOrder = State(initialValue: releaseYearOrder)
    }

    var body: some View {
        Group {
            options
            ForEach(viewModel.releases(for: selectedMode,
                                       order: releaseYearOrder),
                    id: \.title) {
                ReleaseInBandView(release: $0)
                    .padding(.vertical, 8)
            }
        }
    }

    private var options: some View {
        HStack {
            DiscographyModePicker(viewModel: viewModel,
                                  selectedMode: $selectedMode)
            Spacer()
            OrderView(order: $releaseYearOrder, title: "Release year")
        }
    }
}

struct DiscographyView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            ScrollView {
                VStack {
                    DiscographyView(discography: .death, releaseYearOrder: .ascending)
                }
            }
            .padding(.horizontal)
            .background(Color(.systemBackground))
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}

private struct DiscographyModePicker: View {
    @EnvironmentObject private var preferences: Preferences
    @ObservedObject var viewModel: DiscographyViewModel
    @Binding var selectedMode: DiscographyMode

    var body: some View {
        Picker(selection: $selectedMode,
               label: selectedModeView) {
            ForEach(viewModel.modes, id: \.self) { mode in
                Text(viewModel.title(for: mode))
                    .tag(mode.rawValue)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }

    private var selectedModeView: some View {
        Text(viewModel.title(for: selectedMode) + " ≡ ")
            .padding(6)
            .background(preferences.theme.primaryColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
