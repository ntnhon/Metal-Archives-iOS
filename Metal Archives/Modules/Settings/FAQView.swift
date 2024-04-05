//
//  FAQView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/04/2024.
//

import SwiftUI

struct FAQView: View {
    var body: some View {
        Form {
            ForEach(Question.allCases, id: \.self) {
                view(for: $0)
            }
        }
        .navigationTitle("FAQ")
    }

    func view(for question: Question) -> some View {
        NavigationLink(destination: {
            Form {
                Text(question.description)
            }
            .navigationTitle(question.title)
            .navigationBarTitleDisplayMode(.inline)
        }, label: {
            Text(question.title)
        })
    }
}

#Preview {
    NavigationView {
        FAQView()
    }
    .navigationViewStyle(.stack)
    .preferredColorScheme(.dark)
}
