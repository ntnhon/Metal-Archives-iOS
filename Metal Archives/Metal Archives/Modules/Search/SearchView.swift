//
//  SearchView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var showAdvancedSearch = false
    @State private var placeHolderOpacity = 1.0
    @State private var searchTerm = ""
    @State private var isEditing = false
    @State private var simpleSearchType: SimpleSearchType = .bandName

    var body: some View {
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
                .background(GeometryReader {
                    Color.clear.preference(key: ViewOffsetKey.self,
                                           value: -$0.frame(in: .named("scroll")).origin.y)
                })
                .onPreferenceChange(ViewOffsetKey.self) { _ in
                    guard isEditing else { return }
                    withAnimation { isEditing = false }
                    hideKeyboard()
                }
            }
        }
        .navigationBarHidden(true)
        .accentColor(preferences.theme.primaryColor)
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

                    TextField("",
                              text: $searchTerm,
                              onEditingChanged: { isBegin in
                                withAnimation {
                                    isEditing = isBegin
                                }
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
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
    }
}

// https://stackoverflow.com/a/62588295
struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat

    static var defaultValue = CGFloat.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
