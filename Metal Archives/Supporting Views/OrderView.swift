//
//  OrderView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/07/2021.
//

import SwiftUI

struct OrderView: View {
    @EnvironmentObject private var preferences: Preferences
    @Binding var order: Order
    let title: String

    var body: some View {
        HStack {
            Text(title)
            Image(systemName: "arrow.down")
                .rotationEffect(.degrees(order == .descending ? 0 : 180))
                .animation(.default, value: order)
        }
        .padding(8)
        .background(preferences.theme.primaryColor)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture {
            order = order.oppositeOrder
        }
    }
}

private struct OrderViewPreview: View {
    @State private var order: Order = .ascending

    var body: some View {
        OrderView(order: $order, title: "Release year")
    }
}

#Preview {
    OrderViewPreview()
        .environmentObject(Preferences())
}
