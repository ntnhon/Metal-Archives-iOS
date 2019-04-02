//
//  BandSimilarArtistListViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class BandSimilarArtistListViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    var similarArtists: [BandSimilar]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(similarArtists.count) similar artists"
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        SimilarBandTableViewCell.register(with: self.tableView)
    }

}

//MARK: - UITableViewDelegate
extension BandSimilarArtistListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let similarArtist = similarArtists[indexPath.row]
        self.pushBandDetailViewController(urlString: similarArtist.urlString, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension BandSimilarArtistListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.similarArtists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let similarBand = self.similarArtists[indexPath.row]
        let similarBandCell = SimilarBandTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        similarBandCell.bind(band: similarBand)
        
        return similarBandCell
    }
}
