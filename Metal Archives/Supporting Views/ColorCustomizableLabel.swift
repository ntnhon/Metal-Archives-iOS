//
//  ColorCustomizableLabel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 02/11/2022.
//

import SwiftUI

struct ColorCustomizableLabel: View {
    let title: String
    let systemImage: String
    var titleColor: Color = .primary
    var imageColor: Color = .secondary

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(imageColor)
            Text(title)
                .foregroundColor(titleColor)
            Spacer()
        }
    }
}
