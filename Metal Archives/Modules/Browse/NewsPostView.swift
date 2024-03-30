//
//  NewsPostView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import SwiftUI

struct NewsPostView: View {
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.selectedUrl) private var selectedUrl
    let apiService: APIServiceProtocol
    let newsPost: NewsPost

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(newsPost.title)
                    .font(.title)
                    .fontWeight(.bold)

                NavigationLink(destination: {
                    UserView(apiService: apiService, urlString: newsPost.author.urlString)
                }, label: {
                    Text(newsPost.dateString)
                        .font(.callout.italic())
                        .fontWeight(.medium) +
                        Text(" • ") +
                        Text(newsPost.author.name)
                        .fontWeight(.medium)
                        .foregroundColor(preferences.theme.secondaryColor)
                })
                .buttonStyle(.plain)

                Text(newsPost.content)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(newsPost.title)
                .fontWeight(.bold)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                selectedUrl.wrappedValue = newsPost.urlString
            }, label: {
                Image(systemName: "safari")
            })
        }
    }
}
