//
//  SimpleSearchTypeView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/06/2021.
//

import SwiftUI

struct SimpleSearchTypeView: View {
    @EnvironmentObject private var preferences: Preferences
    @Binding var selectedType: SimpleSearchType
    let type: SimpleSearchType

    var body: some View {
        Button(action: {
            selectedType = type
            if preferences.useHaptic {
                Vibration.selection.vibrate()
            }
        }, label: {
            Text(type.rawValue)
                .font(.body)
                .fontWeight(.medium)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .foregroundColor(type == selectedType ? .white : .accentColor)
                .background(type == selectedType ? Color.accentColor : .clear)
                .background(Capsule().stroke(Color.accentColor, lineWidth: 1.0))
                .clipShape(Capsule())
        })
    }
}

struct SimpleSearchTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleSearchTypeView(selectedType: .constant(.bandName), type: .bandName)
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
        SimpleSearchTypeView(selectedType: .constant(.songTitle), type: .bandName)
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}
