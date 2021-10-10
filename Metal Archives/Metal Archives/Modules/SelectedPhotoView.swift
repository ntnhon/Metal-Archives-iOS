//
//  PhotoView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/10/2021.
//

import SwiftUI

struct SelectedPhotoView: View {
    @Environment(\.selectedPhoto) private var selectedPhoto
    var body: some View {
        NavigationView {
            ZStack {
                Image(uiImage: selectedPhoto.wrappedValue?.image ?? .add)
                    .resizable()
                    .scaledToFit()
            }
            .navigationBarItems(trailing:
                                    Button(
                                        action: {
                                            selectedPhoto.wrappedValue = nil
                                        },
                                        label: {
                                            Text("Close")
                                        }))
        }
    }
}

struct SelectedPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedPhotoView()
    }
}
