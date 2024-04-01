//
//  SelectedPhotoView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/10/2021.
//

import SwiftUI

struct SelectedPhotoView: View {
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.selectedPhoto) private var selectedPhoto
    @Environment(\.dismiss) private var dismiss
    @State private var showPhotoOnly = false
    @State private var scaleFactor: CGFloat = 1.0
    @State private var imageSize: CGSize = .zero
    @State private var offset: CGSize = .zero
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            let gestures =
                TapGesture(count: 1)
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
                                    offset = .zero
                                }
                            }
                    )
                    .simultaneously(
                        with: MagnificationGesture()
                            .onChanged { value in
                                showPhotoOnly = true
                                scaleFactor = value.magnitude
                            }
                            .onEnded { _ in
                                scaleFactor = max(1, scaleFactor)
                            }
                    )
                    .simultaneously(
                        with: DragGesture()
                            .onChanged { value in
                                showPhotoOnly = true
                                offset += value.translation
                            }
                            .onEnded { value in
                                if scaleFactor == 1.0 {
                                    showPhotoOnly = false
                                    offset = .zero
                                }
                                if value.location.y - value.startLocation.y > 5 {
                                    selectedPhoto.wrappedValue = nil
                                }
//                            else if offset.width > 0 {
//                                offset.width = 0
//                            } else if imageSize.width * scaleFactor - imageSize.width + offset.width < 0 {
//                                offset.width = -(imageSize.width * scaleFactor - imageSize.width)
//                            }
                            }
                    )
                    .simultaneously(
                        with: LongPressGesture()
                            .onEnded { _ in
                                showShareSheet = true
                            }
                    )

            Color(.systemBackground)
                .ignoresSafeArea()
                .gesture(gestures)

            Image(uiImage: selectedPhoto.wrappedValue?.image ?? .add)
                .resizable()
                .scaledToFit()
                .scaleEffect(scaleFactor, anchor: .center)
                .animation(.default, value: scaleFactor)
                .animation(.default, value: offset)
                .gesture(gestures)
                .offset(offset)
                .modifier(SizeModifier())
                .onPreferenceChange(SizePreferenceKey.self) {
                    imageSize = $0
                }

            VStack {
                HStack {
                    actionButton(imageSystemName: "xmark") {
                        selectedPhoto.wrappedValue = nil
                    }
                    .disabled(showPhotoOnly)

                    Spacer()

                    actionButton(imageSystemName: "square.and.arrow.up") {
                        showShareSheet = true
                    }
                }

                Spacer()

                Text(selectedPhoto.wrappedValue?.description ?? "")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .opacity(showPhotoOnly ? 0 : 1)
            .animation(Animation.linear(duration: 0.15), value: scaleFactor)
            .padding(.vertical)
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(items: [selectedPhoto.wrappedValue?.image ?? .add])
        }
    }

    private func actionButton(imageSystemName: String,
                              action: @escaping () -> Void) -> some View
    {
        Button(action: action) {
            Image(systemName: imageSystemName)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 24)
                .foregroundColor(preferences.theme.primaryColor)
                .padding()
        }
    }
}

#Preview {
    SelectedPhotoView()
}

private extension CGSize {
    static func += (lhs: inout Self, rhs: Self) {
        lhs = CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}
