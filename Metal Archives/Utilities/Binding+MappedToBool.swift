//
//  Binding+MappedToBool.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 31/03/2024.
//

import SwiftUI

extension Binding where Value == Bool {
    init(binding: Binding<(some Any)?>) {
        self.init(get: {
                binding.wrappedValue != nil
            }, set: { newValue in
                if !newValue {
                    binding.wrappedValue = nil
                }
            }
        )
    }
}

extension Binding {
    /// Maps an optional binding to a `Binding<Bool>`.
    /// This can be used to, for example, use an `Error?` object to decide whether or not to show an
    /// alert, without needing to rely on a separately handled `Binding<Bool>`.
    func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        Binding<Bool>(binding: self)
    }
}
