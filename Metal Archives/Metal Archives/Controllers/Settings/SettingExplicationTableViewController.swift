//
//  ThumbnailExplicationTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class SettingExplicationTableViewController: BaseSubSettingsTableViewController {
    @IBOutlet private weak var explicationTextView: UITextView!
    
    var explainThumbnail = false
    var explainWidget = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
        explicationTextView.text = ""
        setTitle()
        setText()
        
        if explainThumbnail {
            Analytics.logEvent("view_settings_explication", parameters: ["Module": "Explain thumbnail"])
        } else if explainWidget {
            Analytics.logEvent("view_settings_explication", parameters: ["Module": "Explain widget"])
        }
    }

    override func initAppearance() {
        super.initAppearance()
        
        explicationTextView.textColor = Settings.currentTheme.bodyTextColor
        explicationTextView.font = Settings.currentFontSize.bodyTextFont
        explicationTextView.backgroundColor = Settings.currentTheme.backgroundColor
    }
    
    private func setTitle() {
        if explainThumbnail {
            simpleNavigationBarView?.setTitle("About Thumbnails")
        } else if explainWidget {
            simpleNavigationBarView?.setTitle("About Today Widget")
        }
    }
    
    private func setText() {
        if explainThumbnail {
            explicationTextView.text = "Metal Archives server limits the number of request that a client can make at a same time (for performance and security issues). You will sometimes find yourself in a list of things with thumbnails, e.g., bands, releases, artists, and labels. As every thumbnail is a request to server, you may notice that sometimes it takes a while to load (it means you're temporarily blocked by the server).\n\nBut no worry, the application handles this situation by retrying requests. It is good to know that thumbnail requests reduce with time as the application smartly caches images. It's up to you to decide."
        } else if explainWidget {
            explicationTextView.text = "Widget is an extension of the application which can be added to your Notification Center along side with other famous default widgets like Weather and Calendar.\n\nMetal Archives widget helps you stay up to date without opening the application."
        }
    }
}

extension SettingExplicationTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
}
