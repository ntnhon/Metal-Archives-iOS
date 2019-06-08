//
//  NewsDetailViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class NewsDetailViewController: BaseViewController {
    @IBOutlet private weak var textView: UITextView!
    
    var news: News!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.textColor = Settings.currentTheme.backgroundColor
        textView.backgroundColor = Settings.currentTheme.bodyTextColor
        textView.font = Settings.currentFontSize.bodyTextFont
        textView.contentInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        view.backgroundColor = Settings.currentTheme.bodyTextColor
        view.tintColor = Settings.currentTheme.backgroundColor
        navigationController?.navigationBar.tintColor = Settings.currentTheme.backgroundColor

        title = news.title
        textView.text = "\(news.htmlBody)\n-\(news.author)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.isScrollEnabled = false
        textView.contentOffset = .zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.isScrollEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let navController = self.navigationController else { return }
        let navPreferredContentSize = navController.preferredContentSize
        let sizeThatFit = textView.sizeThatFits(CGSize(width: navPreferredContentSize.width, height: CGFloat.greatestFiniteMagnitude))
        
        if sizeThatFit.height < navPreferredContentSize.height {
            navController.preferredContentSize = CGSize(width: navPreferredContentSize.width, height: sizeThatFit.height)
        }
    }
    
}
