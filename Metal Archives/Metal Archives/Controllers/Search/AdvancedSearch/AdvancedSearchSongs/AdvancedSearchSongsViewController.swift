//
//  AdvancedSearchSongsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class AdvancedSearchSongsViewController: BaseAdvancedSearchTableViewController {
    @IBOutlet private weak var songTitleTextField: BaseTextField!
    @IBOutlet private weak var exactMatchSongTitleSwitch: UISwitch!
    @IBOutlet private weak var bandNameTextField: BaseTextField!
    @IBOutlet private weak var exactMatchBandNameSwitch: UISwitch!
    @IBOutlet private weak var releaseTitleTextField: BaseTextField!
    @IBOutlet private weak var exactMatchReleaseTitleSwitch: UISwitch!
    @IBOutlet private weak var lyricsTextField: BaseTextField!
    @IBOutlet private weak var genreTextField: BaseTextField!
    @IBOutlet private weak var releaseTypeListLabel: UILabel!
    
    private var selectedReleaseTypes: [ReleaseType] = []
    
    deinit {
        print("AdvancedSearchSongsViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simpleNavigationBarView.setTitle("Advanced Search Songs")
        simpleNavigationBarView.setRightButtonIcon(#imageLiteral(resourceName: "search"))
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            self.performSearch()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let advancedSearchReleaseTypeListViewController as AdvancedSearchReleaseTypeListViewController:
            advancedSearchReleaseTypeListViewController.selectedReleaseTypes = self.selectedReleaseTypes
            advancedSearchReleaseTypeListViewController.simpleNavigationBarView = simpleNavigationBarView
            advancedSearchReleaseTypeListViewController.delegate = self
            
        case let advancedSearchSongsResultsViewController as AdvancedSearchSongsResultsViewController:
            if let optionsList = sender as? String {
                advancedSearchSongsResultsViewController.optionsList = optionsList
                advancedSearchSongsResultsViewController.simpleNavigationBarView = simpleNavigationBarView
            }
            
        default:
            break
        }
    }
    
    private func updateReleaseTypeLabel() {
        self.releaseTypeListLabel.text = self.generateSelectedReleaseTypeString()
    }
    
    func performSearch() {
        var optionsList = ""
        
        //Song title
        optionsList += "songTitle="
        if let songTitle = self.songTitleTextField.text {
            optionsList += songTitle
        }
        optionsList += "&"
        
        //Exact match song title
        let exactSongMatch = self.exactMatchSongTitleSwitch.isOn ? 1 : 0
        optionsList += "exactSongMatch=\(exactSongMatch)&"
        
        //Band name
        optionsList += "bandName="
        if let bandName = self.bandNameTextField.text {
            optionsList += bandName
        }
        optionsList += "&"
        
        //Exact match band name
        let exactBandMatch = self.exactMatchBandNameSwitch.isOn ? 1 : 0
        optionsList += "exactBandMatch=\(exactBandMatch)&"
        
        //Release title
        optionsList += "releaseTitle="
        if let releaseTitle = self.releaseTitleTextField.text {
            optionsList += releaseTitle
        }
        optionsList += "&"
        
        //Exact match release title
        let exactReleaseMatch = self.exactMatchReleaseTitleSwitch.isOn ? 1 : 0
        optionsList += "exactReleaseMatch=\(exactReleaseMatch)&"
        
        //Lyrics
        optionsList += "lyrics="
        if let lyrics = self.lyricsTextField.text {
            optionsList += lyrics
        }
        optionsList += "&"
        
        //Genre
        optionsList += "genre="
        if let genre = self.genreTextField.text {
            optionsList += genre
        }
        optionsList += "&"
        
        //Release type
        self.selectedReleaseTypes.forEach({
            optionsList += "releaseType[]=\($0.rawValue)&"
        })
        
        self.performSegue(withIdentifier: "ShowResult", sender: optionsList)
        
        Analytics.logEvent("perform_advanced_search_songs", parameters: nil)
    }
}

//MARK: - UITableViewDelegate
extension AdvancedSearchSongsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - AdvancedSearchReleaseTypeListViewControllerDelegate
extension AdvancedSearchSongsViewController: AdvancedSearchReleaseTypeListViewControllerDelegate {
    func didUpdateSelectedReleaseTypes(_ releaseTypes: [ReleaseType]) {
        self.selectedReleaseTypes = releaseTypes
        self.updateReleaseTypeLabel()
        self.tableView.reloadData()
        
        Analytics.logEvent("change_advanced_search_option", parameters: ["option": "Release types"])
    }
    
    private func generateSelectedReleaseTypeString() -> String {
        if self.selectedReleaseTypes.count == 0 || self.selectedReleaseTypes.count == ReleaseType.allCases.count {
            return "Any"
        } else {
            var releasesName: String = ""
            for i in 0..<self.selectedReleaseTypes.count {
                let eachRelease = self.selectedReleaseTypes[i]
                if i == self.selectedReleaseTypes.count - 1 {
                    releasesName.append("\(eachRelease.description)")
                } else {
                    releasesName.append("\(eachRelease.description), ")
                }
            }
            
            return releasesName
        }
    }
}
