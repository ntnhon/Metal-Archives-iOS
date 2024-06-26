//
//  PhotoSelectableViewModifier.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/10/2021.
//

import SwiftUI

struct PhotoSelectableViewModifier: ViewModifier {
    @EnvironmentObject private var preferences: Preferences
    @State private var selectedPhoto: Photo?

    func body(content: Content) -> some View {
        let photoBinding = Binding<Bool>(get: { selectedPhoto != nil },
                                         set: { _ in })

        content
            .fullScreenCover(isPresented: photoBinding) {
                SelectedPhotoView()
                    .preferredColorScheme(.dark)
                    .environmentObject(preferences)
            }
            .environment(\.selectedPhoto, $selectedPhoto)
    }
}

struct SelectedPhotoKey: EnvironmentKey {
    static let defaultValue: Binding<Photo?> = .constant(nil)
}

extension EnvironmentValues {
    var selectedPhoto: Binding<Photo?> {
        get { self[SelectedPhotoKey.self] }
        set { self[SelectedPhotoKey.self] = newValue }
    }
}
