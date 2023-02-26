//
//  ToastViewModifier.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import AlertToast
import SwiftUI

struct ToastViewModifier: ViewModifier {
    @State private var message: String?

    func body(content: Content) -> some View {
        content
            .alertToastMessage($message)
            .environment(\.toastMessage, $message)
    }
}

struct ToastMessageKey: EnvironmentKey {
    static let defaultValue: Binding<String?> = .constant(nil)
}

extension EnvironmentValues {
    var toastMessage: Binding<String?> {
        get { self[ToastMessageKey.self] }
        set { self[ToastMessageKey.self] = newValue }
    }
}
