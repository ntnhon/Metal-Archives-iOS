//
//  ActivityView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/10/2021.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var items: [Any]
    var activities: [UIActivity]?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
        controller.completionWithItemsHandler = { _, _, _, _ in
            presentationMode.wrappedValue.dismiss()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
