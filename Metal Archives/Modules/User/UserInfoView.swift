//
//  UserInfoView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 07/11/2022.
//

import SwiftUI

struct UserInfoView: View {
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.selectedUrl) private var selectedUrl
    let user: User

    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                ColorCustomizableLabel(title: user.rank.title,
                                       systemImage: "arrow.up.and.person.rectangle.portrait",
                                       titleColor: user.rank.color)

                ColorCustomizableLabel(title: user.points, systemImage: "star.circle.fill")

                if let fullName = user.fullName {
                    ColorCustomizableLabel(title: fullName, systemImage: "person.text.rectangle.fill")
                }

                if #available(iOS 16, *) {
                    ColorCustomizableLabel(title: user.age, systemImage: "birthday.cake.fill")
                } else {
                    ColorCustomizableLabel(title: user.age, systemImage: "calendar")
                }

                ColorCustomizableLabel(title: user.gender, systemImage: "person.fill.questionmark")

                ColorCustomizableLabel(title: user.country.nameAndFlag, systemImage: "house.fill")

                if let website = user.homepage {
                    ColorCustomizableLabel(title: website.title,
                                           systemImage: "link.circle.fill",
                                           titleColor: preferences.theme.primaryColor)
                        .onTapGesture {
                            selectedUrl.wrappedValue = website.urlString
                        }
                }

                if let favoriteGenres = user.favoriteGenres {
                    ColorCustomizableLabel(title: favoriteGenres, systemImage: "guitars.fill")
                }
            }
            .padding(.horizontal)

            Color(.systemGray6)
                .frame(height: 10)
        }
    }
}
