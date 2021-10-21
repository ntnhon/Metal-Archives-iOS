//
//  PhotoView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/10/2021.
//

import SwiftUI

struct SelectedPhotoView: View {
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.selectedPhoto) private var selectedPhoto
    @State private var showPhotoOnly = false
    @State private var scaleFactor: CGFloat = 1.0

    var body: some View {
        ZStack {
            let tapGesture = TapGesture(count: 1)
                .onEnded {
                    showPhotoOnly.toggle()
                }
                .simultaneously(
                    with: TapGesture(count: 2)
                        .onEnded {
                            if scaleFactor == 1.0 {
                                scaleFactor = 2.2
                            } else {
                                scaleFactor = 1.0
                            }
                        }
                )

            let magnificationGesture = MagnificationGesture()
                .onChanged { value in
                    showPhotoOnly = true
                    scaleFactor = value.magnitude
                }
                .onEnded { _ in
                    scaleFactor = max(1, scaleFactor)
                }

            Color(.systemBackground)
                .ignoresSafeArea()
                .gesture(tapGesture)
                .gesture(magnificationGesture)

            Image(uiImage: selectedPhoto.wrappedValue?.image ?? .add)
                .resizable()
                .scaledToFit()
                .scaleEffect(scaleFactor)
                .animation(.default)
                .gesture(tapGesture)
                .gesture(magnificationGesture)

            VStack {
                HStack {
                    Button(action: {
                        selectedPhoto.wrappedValue = nil
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(preferences.theme.primaryColor)
                            .padding()
                    })
                    .disabled(showPhotoOnly)
                    .padding(.leading, -12)

                    Spacer()
                }

                Spacer()

                Text(selectedPhoto.wrappedValue?.description ?? "")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .opacity(showPhotoOnly ? 0 : 1)
            .animation(Animation.linear(duration: 0.15))
        }
    }
}

struct SelectedPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedPhotoView()
    }
}
