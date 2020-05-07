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
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var copyButton: UIBarButtonItem!
    
    var lyricID: String?
    var songTitle: String?
    
    private var numberOfTries = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lyricTextView.text = nil
        lyricTextView.textColor = Settings.currentTheme.backgroundColor
        lyricTextView.backgroundColor = Settings.currentTheme.bodyTextColor
        lyricTextView.font = Settings.currentFontSize.bodyTextFont
        
        view.backgroundColor = Settings.currentTheme.bodyTextColor
        view.tintColor = Settings.currentTheme.backgroundColor
        navigationController?.navigationBar.tintColor = Settings.currentTheme.titleColor
        
        if #available(iOS 13.0, *) {
            activityIndicatorView.style = .large
        } else {
            activityIndicatorView.style = .gray
        }
        
        copyButton.isEnabled = false
        
        fetchLyric()
    }
    
    private func fetchLyric() {
        guard let lyricID = lyricID else {
            Toast.displayMessageShortly("Lyric id is undefined")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        if numberOfTries == Settings.numberOfRetries {
            //Dimiss controller
            Toast.displayMessageShortly("Error loading lyric. Please retry.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        numberOfTries += 1
        activityIndicatorView.startAnimating()
        
        RequestService.Release.fetchLyric(lyricId: lyricID) { [weak self] result in
            guard let self = self else { return }
            self.activityIndicatorView.stopAnimating()
            
            switch result {
            case .success(let lyric):
                self.title = self.songTitle
                self.copyButton.isEnabled = true
                self.lyricTextView.text = lyric.htmlToString
                self.adjustPreferredContentSize()
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
                self.fetchLyric()
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
    
    @IBAction private func copyButtonTapped() {
        Toast.displayMessageShortly("Copied lyric")
        UIPasteboard.general.string = lyricTextView.text
    }
}
