//
//  SearchView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var preferences: Preferences
    @State private var showAdvancedSearch = false
    @State private var placeHolderOpacity = 1.0
    @State private var searchTerm = ""
    @State private var isEditing = false
    @State private var simpleSearchType: SimpleSearchType = .bandName

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    NavigationLink(destination: AdvancedSearchView(), isActive: $showAdvancedSearch) {
                        EmptyView()
                    }
                    LazyVStack(alignment: .leading) {
                        searchSection
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
        }
        .accentColor(preferences.theme.primaryColor(for: colorScheme))
    }

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Spacer()
                Button(action: {
                    showAdvancedSearch = true
                }, label: {
                    Text("Advanced search")
                        .fontWeight(.semibold)
                })
            }
            .padding(.bottom, 30)

            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.title)
                    .foregroundColor(.secondary)
                ZStack(alignment: .leading) {
                    Text(simpleSearchType.rawValue)
                        .font(.title.weight(.medium))
                        .foregroundColor(.secondary)
                        .opacity(searchTerm.isEmpty ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.2))

                    TextField("",
                              text: $searchTerm,
                              onEditingChanged: { isBegin in
                                isEditing = isBegin
                              },
                              onCommit: {
                                print(searchTerm)
                              })
                        .autocapitalization(.sentences)
                        .disableAutocorrection(true)
                        .keyboardType(.webSearch)
                        .font(.title.weight(.medium))
                }

                if isEditing && !searchTerm.isEmpty {
                    Button(action: {
                        searchTerm = ""
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.primary)
                    })
                }
            }
            Rectangle()
                .fill(isEditing ? Color.accentColor : Color.secondary)
                .frame(height: isEditing ? CGFloat(3.0) : 2.0)
                .animation(.easeInOut(duration: 0.2))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer()
                        .frame(width: 20)
                    ForEach(SimpleSearchType.allCases, id: \.self) {
                        SimpleSearchTypeView(selectedType: $simpleSearchType, type: $0)
                    }
                }
            }
            .padding(.horizontal, -20)
            .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity)
//        .background(Color(.systemBackground).padding(-20))
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(Preferences())
    }
}
