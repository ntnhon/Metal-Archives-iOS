//
//  ThumbnailExplicationTableViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class SettingExplicationTableViewController: UITableViewController {
    @IBOutlet private weak var explicationTextView: UITextView!
    
    var explainThumbnail = false
    var explainWidget = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAppearance()
        self.explicationTextView.text = ""
        self.setTitle()
        self.setText()
        
        if self.explainThumbnail {
            Analytics.logEvent(AnalyticsEvent.ViewSettingsExplication, parameters: ["Module": "Explain thumbnail"])
        } else if self.explainWidget {
            Analytics.logEvent(AnalyticsEvent.ViewSettingsExplication, parameters: ["Module": "Explain widget"])
        }
    }

    private func initAppearance() {
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        
        self.explicationTextView.textColor = Settings.currentTheme.bodyTextColor
        self.explicationTextView.font = Settings.currentFontSize.bodyTextFont
        self.explicationTextView.backgroundColor = Settings.currentTheme.backgroundColor
    }
    
    private func setTitle() {
        if self.explainThumbnail {
            self.title = "About thumbnails"
        } else if self.explainWidget {
            self.title = "About widget"
        }
    }
    
    private func setText() {
        if self.explainThumbnail {
            self.explicationTextView.text = "Metal Archives server limits the number of request that a client can make at a same time (for performance and security issues). You will find yourself regularly in a list of things with thumbnails, e.g., bands, releases, artists, and labels. As every thumbnail is a request to server, you may notice that sometimes it takes a while for loading stuffs (it means you're temporarily blocked by the server).\n\nBut no worry, the application handles this situation by retrying requests, all you have to do is wait. It is good to know that thumbnail requests reduce with time as the application smartly caches images. It's up to you to see."
        } else if self.explainWidget {
            self.explicationTextView.text = "Widget is an extension of the application which can be added to your Notification Center along side with other famous default widgets like Weather and Calendar.\n\nMetal Archives widget helps you stay updated without opening the application."
        }
        
    }
}
