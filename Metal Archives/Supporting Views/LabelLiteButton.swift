//
//  LabelLiteButton.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/10/2022.
//

import SwiftUI

struct LabelLiteButton: View {
    @EnvironmentObject private var preferences: Preferences
    let label: LabelLite
    let onSelect: (String) -> Void

    var body: some View {
        Button(action: {
                   if let urlString = label.thumbnailInfo?.urlString {
                       onSelect(urlString)
                   }
               },
               label: {
                   Text(label.name)
                       .fontWeight(label.thumbnailInfo == nil ? .regular : .bold)
                       .foregroundColor(
                           label.thumbnailInfo == nil ? .primary : preferences.theme.primaryColor)
               })
    }
}
