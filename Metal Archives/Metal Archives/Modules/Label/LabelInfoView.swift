//
//  LabelInfoView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 05/11/2022.
//

import SwiftUI

struct LabelInfoView: View {
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.selectedUrl) private var selectedUrl
    let label: LabelDetail
    let onSelectLabel: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(label.name)
                .font(.title)
                .fontWeight(.bold)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .background(GradientBackgroundView())

            VStack(alignment: .leading, spacing: 10) {
                ColorCustomizableLabel(title: label.country.nameAndFlag, systemImage: "house.fill")

                ColorCustomizableLabel(title: label.address, systemImage: "location.fill")

                ColorCustomizableLabel(title: label.phoneNumber, systemImage: "phone.fill")

                ColorCustomizableLabel(title: label.status.rawValue,
                                       systemImage: "waveform.path",
                                       titleColor: label.status.color)

                ColorCustomizableLabel(title: label.specialties, systemImage: "guitars.fill")

                ColorCustomizableLabel(title: label.foundingDate, systemImage: "calendar")

                if let parent = label.parentLabel {
                    let urlString = parent.thumbnailInfo?.urlString
                    ColorCustomizableLabel(title: parent.name,
                                           systemImage: "building.2.fill",
                                           titleColor: urlString != nil ?
                                           preferences.theme.primaryColor : .primary)
                    .onTapGesture {
                        if let urlString {
                            onSelectLabel(urlString)
                        }
                    }
                }

                ColorCustomizableLabel(title: label.onlineShopping, systemImage: "cart.fill")

                if let website = label.website {
                    ColorCustomizableLabel(title: website.title,
                                           systemImage: "link.circle.fill",
                                           titleColor: preferences.theme.primaryColor)
                        .onTapGesture {
                            selectedUrl.wrappedValue = website.urlString
                        }
                }

                ColorCustomizableLabel(title: label.modificationInfo.summary, systemImage: "clock.fill")
            }
            .padding([.horizontal, .bottom])
            .background(Color(.systemBackground))
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }

        Color(.systemGray6)
            .frame(height: 10)
    }
}
