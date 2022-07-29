//
//  ActivityView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/10/2021.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    var items: [Any]
    var activities: [UIActivity]?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
        controller.completionWithItemsHandler = { _, _, _, _ in
            dismiss()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
