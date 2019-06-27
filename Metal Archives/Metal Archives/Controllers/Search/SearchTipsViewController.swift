//
//  SearchTipsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 10/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import AttributedLib
import FirebaseAnalytics

final class SearchTipsViewController: DismissableOnSwipeViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    @IBOutlet private weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        showTips()
        handleSimpleNavigationBarViewActions()
        Analytics.logEvent(AnalyticsEvent.ViewSearchTips, parameters: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.contentOffset = .zero
    }
    
    override func initAppearance() {
        super.initAppearance()
        textView.backgroundColor = Settings.currentTheme.backgroundColor
    }
    
    private func handleSimpleNavigationBarViewActions() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle("Search Tips 💡")
        simpleNavigationBarView.setLeftButtonIcon(#imageLiteral(resourceName: "down"))
        simpleNavigationBarView.setRightButtonIcon(nil)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.dismissToBottom()
        }
    }
    
    private func showTips() {
        let tipsMutableAttrString = NSMutableAttributedString()
        
        tipsMutableAttrString.append("Search features\n".at.attributed(with: titleAttributes))
        tipsMutableAttrString.append("Unlike the first version of the site, the search engine supports many powerful (and standard, really) search features.\n\n".at.attributed(with: bodyTextAttributes))
        tipsMutableAttrString.append("Keyword matching\n".at.attributed(with: secondaryTitleAttributes))
        tipsMutableAttrString.append("By default, a keyword search will return results containing the full keyword (or similar words). For example, searching for bands with the keyword hell will return all bands containing the word \"hell\", including bands such as \"Hell Patrol\" or \"Black Hell\". It also considers words with case-change as different words; that means \"HellBorn\" will also be returned in the results (since it treats the name as \"Hell Born\" internally), but not \"Hellborn\".\n\n".at.attributed(with: indentedBodyTextAttributes))
        tipsMutableAttrString.append("Multiple keywords\n".at.attributed(with: secondaryTitleAttributes))
        tipsMutableAttrString.append("Separate all your keywords by spaces. The order of the keywords does not matter: searching for black death will also return results containing \"death/black\". By default, the boolean behaviour is AND, meaning that searching for black death will get results containing both \"black\" AND \"death\".\n\n".at.attributed(with: indentedBodyTextAttributes))
        tipsMutableAttrString.append("Searching phrases\n".at.attributed(with: secondaryTitleAttributes))
        tipsMutableAttrString.append("If you want to match on an exact phrase, wrap it in quotes: searching for take me away (songs) will return the song \"Take the World Away From Me\", but searching for \"take me away\" (with the quotes) will only return song titles containing the actual phrase.\n\n".at.attributed(with: indentedBodyTextAttributes))
        tipsMutableAttrString.append("Wildcards\n".at.attributed(with: secondaryTitleAttributes))
        tipsMutableAttrString.append("If you want to search for part of a word, use the * symbol as a wildcard. In the above example, searching for Hell will not return results containing the word \"hellish\". For that, you can search for Hell*. Likewise, searching for Hel* will return results containing \"Hell\", \"Helm\", \"Helion\", etc. Wildcards can be placed anywhere: searching for *iron will return both \"Iron Maiden\" and \"Apeiron\". Searching for *iron* will also return \"Ironsword\" and \"Dramatic Irony\".\n\n".at.attributed(with: indentedBodyTextAttributes))
        tipsMutableAttrString.append("Excluding keywords\n".at.attributed(with: secondaryTitleAttributes))
        tipsMutableAttrString.append("Use the - operator to exclude terms from your search. Say you want to search for death metal bands, but want to exclude melodeath and deathcore, then you would search for death metal -deathcore -melodic.\n\n".at.attributed(with: indentedBodyTextAttributes))
        tipsMutableAttrString.append("Boolean operators\n".at.attributed(with: secondaryTitleAttributes))
        tipsMutableAttrString.append("By default, searching with multiple keywords is treated as an AND operator. If you want results containing either \"black\" OR \"death\", use the || symbol. Searching for black death is the equivalent of black AND death, while searching for black || death is the equivalent of \"black OR death\".\n\n".at.attributed(with: indentedBodyTextAttributes))
        tipsMutableAttrString.append("Advanced search\n".at.attributed(with: titleAttributes))
        tipsMutableAttrString.append("You can also perform an advanced search, by combining several available filters. For example, you can view a list of all the thrash metal bands from Norway, or all the pagan black metal bands in Germany formed before 1995, or all the disbanded satanic power metal bands from Gothenburg, Sweden 😉.\n\n".at.attributed(with: bodyTextAttributes))
        tipsMutableAttrString.append("New in v2:\n".at.attributed(with: bodyTextAttributes))
        tipsMutableAttrString.append("- You can search by year of formation/active, and specify a year range. To search for all bands formed exactly in 1980, put the year in both fields; to search for all bands formed before (and up to) 1980, leave the first year blank and enter 1980 in the second field, and so on.\n".at.attributed(with: indentedBodyTextAttributes))
        tipsMutableAttrString.append("- You can also perform an advanced search on albums. You can specify date ranges (year and month); like for band years, you can leave blanks for looser ranges.\n".at.attributed(with: indentedBodyTextAttributes))
        tipsMutableAttrString.append("- You can perform an advanced search for songs, including in the lyrics.\n".at.attributed(with: indentedBodyTextAttributes))
        
        textView.attributedText = tipsMutableAttrString
    }
}
