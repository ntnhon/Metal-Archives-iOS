//
//  LyricViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster

final class LyricViewController: BaseViewController {
    @IBOutlet private weak var lyricTextView: UITextView!
    
    var lyricID: String!
    private var numberOfTries = 0
    
    deinit {
        print("LyricViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lyricTextView.text = ""
        lyricTextView.textColor = Settings.currentTheme.backgroundColor
        lyricTextView.backgroundColor = Settings.currentTheme.bodyTextColor
        lyricTextView.font = Settings.currentFontSize.bodyTextFont
        
        view.backgroundColor = Settings.currentTheme.bodyTextColor
        view.tintColor = Settings.currentTheme.backgroundColor
        navigationController?.navigationBar.tintColor = Settings.currentTheme.backgroundColor
        fetchLyric()
    }
    
    private func fetchLyric() {
        if numberOfTries == Settings.numberOfRetries {
            //Dimiss controller
            Toast.displayMessageShortly("Error loading lyric. Please retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        numberOfTries += 1
        
        MetalArchivesAPI.fetchLyric(lyricID: lyricID) { [weak self] (lyric, error) in
            if let `lyric` = lyric {
                DispatchQueue.main.async  {
                    self?.lyricTextView.text = lyric.htmlToString
                    self?.adjustPreferredContentSize()
                }
            } else {
                self?.fetchLyric()
            }
        }
    }
    
    private func adjustPreferredContentSize() {
        guard let navController = navigationController else { return }
        let navPreferredContentSize = navController.preferredContentSize
        let sizeThatFit = lyricTextView.sizeThatFits(CGSize(width: navPreferredContentSize.width, height: CGFloat.greatestFiniteMagnitude))
        
        if sizeThatFit.height < navPreferredContentSize.height {
            navController.preferredContentSize = CGSize(width: navPreferredContentSize.width, height: sizeThatFit.height)
        }
    }
}
