//
//  RootPresentationModeKey.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/07/2021.
//

import SwiftUI

// https://github.com/Whiffer/SwiftUI-PopToRootExample/
struct RootPresentationModeKey: EnvironmentKey {
    static let defaultValue: Binding<RootPresentationMode> = .constant(RootPresentationMode())
}

extension EnvironmentValues {
    var rootPresentationMode: Binding<RootPresentationMode> {
        get { self[RootPresentationModeKey.self] }
        set { self[RootPresentationModeKey.self] = newValue }
    }
}

typealias RootPresentationMode = Bool

extension RootPresentationMode {
    mutating func dismiss() {
        self.toggle()
    }
}
