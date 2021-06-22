//
//  AdvancedSearchTipsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/06/2021.
//

import SwiftUI

struct AdvancedSearchTipsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Search features")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)

                    Text(kSearchFeatures)
                        .padding(.top, 2)

                    Group {
                        Text("Keyword matching")
                            .fontWeight(.semibold)
                            .padding(.top)
                        Text(kKeywordMatching)
                            .padding(.leading, 32)

                        Text("Multiple keywords")
                            .fontWeight(.semibold)
                            .padding(.top)
                        Text(kMultipleKeywords)
                            .padding(.leading, 32)

                        Text("Searching phrases")
                            .fontWeight(.semibold)
                            .padding(.top)
                        Text(kSearchingPhrases)
                            .padding(.leading, 32)
                    }

                    Group {
                        Text("Wildcards")
                            .fontWeight(.semibold)
                            .padding(.top)
                        Text(kWildcards)
                            .padding(.leading, 32)

                        Text("Excluding keywords")
                            .fontWeight(.semibold)
                            .padding(.top)
                        Text(kExcludingKeywords)
                            .padding(.leading, 32)

                        Text("Boolean operators")
                            .fontWeight(.semibold)
                            .padding(.top)
                        Text(kBooleanOperators)
                            .padding(.leading, 32)
                    }

                    Text("Advanced search")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                        .padding(.top)

                    Text(kAdvancedSearch)
                        .padding(.top, 2)
                }
            }
            .padding([.horizontal])
            .navigationBarItems(trailing:
                                    Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }, label: {
                                        Image(systemName: "xmark")
                                    })
            )
            .navigationTitle("Search tips")
        }
        .accentColor(preferences.theme.primaryColor(for: colorScheme))
    }
}

struct AdvancedSearchTipsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSearchTipsView()
            .environmentObject(Preferences())
    }
}

// swiftlint:disable line_length
private let kSearchFeatures = """
    Unlike the first version of the site, the search engine supports many powerful (and standard, really) search features.
    """

private let kKeywordMatching = """
    By default, a keyword search will return results containing the full keyword (or similar words). For example, searching for bands with the keyword hell will return all bands containing the word "hell", including bands such as "Hell Patrol" or "Black Hell". It also considers words with case-change as different words; that means "HellBorn" will also be returned in the results (since it treats the name as "Hell Born" internally), but not "Hellborn".
    """

private let kMultipleKeywords = """
    Separate all your keywords by spaces. The order of the keywords does not matter: searching for black death will also return results containing "death/black". By default, the boolean behaviour is AND, meaning that searching for black death will get results containing both "black" AND "death".
    """

private let kSearchingPhrases = """
    If you want to match on an exact phrase, wrap it in quotes: searching for take me away (songs) will return the song "Take the World Away From Me", but searching for "take me away" (with the quotes) will only return song titles containing the actual phrase.
    """

private let kWildcards = """
    If you want to search for part of a word, use the * symbol as a wildcard. In the above example, searching for Hell will not return results containing the word "hellish". For that, you can search for Hell*. Likewise, searching for Hel* will return results containing "Hell", "Helm", "Helion", etc. Wildcards can be placed anywhere: searching for *iron will return both "Iron Maiden" and "Apeiron". Searching for *iron* will also return "Ironsword" and "Dramatic Irony".
    """

private let kExcludingKeywords = """
    Use the - operator to exclude terms from your search. Say you want to search for death metal bands, but want to exclude melodeath and deathcore, then you would search for death metal -deathcore -melodic.
    """

private let kBooleanOperators = """
    By default, searching with multiple keywords is treated as an AND operator. If you want results containing either "black" OR "death", use the || symbol. Searching for black death is the equivalent of black AND death, while searching for black || death is the equivalent of "black OR death".
    """

private let kAdvancedSearch = """
    You can also perform an advanced search, by combining several available filters. For example, you can view a list of all the thrash metal bands from Norway, or all the pagan black metal bands in Germany formed before 1995, or all the disbanded satanic power metal bands from Gothenburg, Sweden ;).

    New in v2: you can search by year of formation/active, and specify a year range. To search for all bands formed exactly in 1980, put the year in both fields; to search for all bands formed before (and up to) 1980, leave the first year blank and enter 1980 in the second field, and so on.

    You can also perform an advanced search on albums. You can specify date ranges (year and month); like for band years, you can leave blanks for looser ranges.

    New in v2: you can perform an advanced search for songs, including in the lyrics.
    """
