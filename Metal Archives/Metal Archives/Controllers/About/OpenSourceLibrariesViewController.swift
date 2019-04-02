//
//  OpenSourceLibrariesViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class OpenSourceLibrariesViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var libraries: [Library]!
    
    override func viewDidLoad() {
        self.initLibraries()
        super.viewDidLoad()
        self.title = "Open source libraries"
    }

    override func initAppearance() {
        super.initAppearance()
        self.tableView.backgroundColor = Settings.currentTheme.tableViewBackgroundColor
        self.tableView.separatorColor = Settings.currentTheme.tableViewSeparatorColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        DetailTableViewCell.register(with: self.tableView)
    }
    
    private func initLibraries() {
        guard let url = Bundle.main.url(forResource: "OpenSourceLibraries", withExtension: "plist") else  {
            assertionFailure("Error loading list of open source library. File not found.")
            return
        }
        
        guard let array = NSArray(contentsOf: url) as? [[String]] else {
            assertionFailure("Error loading list of open source library. Unknown format.")
            return
        }
        
        self.libraries = Array()
        
        array.forEach({
            let library = Library(name: $0[0], copyright: $0[1], copyrightDetail: $0[2])
            self.libraries.append(library)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let libraryCopyrightViewController as LibraryCopyrightViewController:
            if let selectedLibrary = sender as? Library {
                libraryCopyrightViewController.library = selectedLibrary
            }
        default:
            break
        }
    }
}

//MARK: - UITableViewDelegate
extension OpenSourceLibrariesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedLibrary = self.libraries[indexPath.row]
        self.performSegue(withIdentifier: "ShowLibraryCopyright", sender: selectedLibrary)
    }
}

//MARK: - UITableViewDataSource
extension OpenSourceLibrariesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = self.libraries else {
            assertionFailure("Error loading libraries")
            return 0
        }
        return self.libraries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DetailTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.accessoryType = .disclosureIndicator
        let library = self.libraries[indexPath.row]
        cell.fill(withTitle: library.name, detail: library.copyright)
        return cell
    }
}
