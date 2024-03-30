//
//  DetailView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/12/2022.
//

import SwiftUI

enum Detail {
    case band(String)
    case artist(String)
    case release(String)
    case label(String)
    case review(String)
    case user(String)
}

struct DetailView: View {
    @Binding var detail: Detail?
    let apiService: APIServiceProtocol

    var body: some View {
        let detailBinding = Binding<Bool>(get: {
            detail != nil
        }, set: { newValue in
            if !newValue {
                detail = nil
            }
        })
        NavigationLink(
            isActive: detailBinding,
            destination: {
                if let detail {
                    switch detail {
                    case let .band(urlString):
                        BandView(apiService: apiService, bandUrlString: urlString)
                    case let .artist(urlString):
                        ArtistView(apiService: apiService, urlString: urlString)
                    case let .release(urlString):
                        ReleaseView(apiService: apiService, urlString: urlString, parentRelease: nil)
                    case let .label(urlString):
                        LabelView(apiService: apiService, urlString: urlString)
                    case let .review(urlString):
                        ReviewView(apiService: apiService, urlString: urlString)
                    case let .user(urlString):
                        UserView(apiService: apiService, urlString: urlString)
                    }
                } else {
                    EmptyView()
                }
            },
            label: {
                EmptyView()
            }
        )
    }
}
