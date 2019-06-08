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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.lyricTextView.text = ""
        self.lyricTextView.textColor = Settings.currentTheme.backgroundColor
        self.lyricTextView.backgroundColor = Settings.currentTheme.bodyTextColor
        self.lyricTextView.font = Settings.currentFontSize.bodyTextFont
        
        self.view.backgroundColor = Settings.currentTheme.bodyTextColor
        self.view.tintColor = Settings.currentTheme.backgroundColor
        self.navigationController?.navigationBar.tintColor = Settings.currentTheme.backgroundColor
        self.fetchLyric()
    }
    
    private func fetchLyric() {
        if self.numberOfTries == Settings.numberOfRetries {
            //Dimiss controller
            Toast.displayMessageShortly("Error loading lyric. Please retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        self.numberOfTries += 1
        
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
        guard let navController = self.navigationController else { return }
        let navPreferredContentSize = navController.preferredContentSize
        let sizeThatFit = self.lyricTextView.sizeThatFits(CGSize(width: navPreferredContentSize.width, height: CGFloat.greatestFiniteMagnitude))
        
        if sizeThatFit.height < navPreferredContentSize.height {
            navController.preferredContentSize = CGSize(width: navPreferredContentSize.width, height: sizeThatFit.height)
        }
    }
}
