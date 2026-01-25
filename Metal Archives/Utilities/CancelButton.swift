//
//  CancelButton.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/01/2026.
//

import SwiftUI

struct CancelButton: View {
    var action: (() -> Void)?

    var body: some View {
        Button(role: .cancel,
               action: { action?() },
               label: { Text("Cancel") })
    }
}
