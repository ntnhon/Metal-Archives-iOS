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
                    case .band(let urlString):
                        BandView(apiService: apiService, bandUrlString: urlString)
                    case .artist(let urlString):
                        ArtistView(apiService: apiService, urlString: urlString)
                    case .release(let urlString):
                        ReleaseView(apiService: apiService, urlString: urlString, parentRelease: nil)
                    case .label(let urlString):
                        LabelView(apiService: apiService, urlString: urlString)
                    case .user(let urlString):
                        UserView(apiService: apiService, urlString: urlString)
                    }
                } else {
                    EmptyView()
                }
            },
            label: {
                EmptyView()
            })
    }
}
