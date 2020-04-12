//
//  MyCollectionViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import Alamofire
import MBProgressHUD

final class MyCollectionViewController: RefreshableViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    
    var myCollection: MyCollection = .collection
    
    private var collectionPagableManager: PagableManager<ReleaseCollection>!
    private var wantedPagableManager: PagableManager<ReleaseWanted>!
    private var tradePagableManager: PagableManager<ReleaseTrade>!
    
    deinit {
        print("MyBookmarksViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleSimpleNavigationBarViewActions()
        setUpTableView()
        initPagableManagers()
        
        switch myCollection {
        case .collection: collectionPagableManager.fetch()
        case .wanted: wantedPagableManager.fetch()
        case .trade: tradePagableManager.fetch()
        }
    }
    
    private func handleSimpleNavigationBarViewActions() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle(myCollection.description)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        simpleNavigationBarView.setRightButtonIcon(nil)
    }
    
    private func setUpTableView() {
        LoadingTableViewCell.register(with: tableView)
        ReleaseInCollectionTableViewCell.register(with: tableView)
    }
    
    private func initPagableManagers() {
        switch myCollection {
        case .collection:
            collectionPagableManager = PagableManager<ReleaseCollection>()
            collectionPagableManager.delegate = self
            
        case .wanted:
            wantedPagableManager = PagableManager<ReleaseWanted>()
            wantedPagableManager.delegate = self
            
        case .trade:
            tradePagableManager = PagableManager<ReleaseTrade>()
            tradePagableManager.delegate = self
        }
    }
    
    override func refresh() {
        switch myCollection {
        case .collection:
            collectionPagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.collectionPagableManager.fetch()
            }
            
        case .wanted:
            wantedPagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.wantedPagableManager.fetch()
            }
            
        case .trade:
            tradePagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.tradePagableManager.fetch()
            }
        }
        
        tableView.reloadData()
    }
}

// MARK: - View details & Edit note
extension MyCollectionViewController {
    private func getRelease(for indexPath: IndexPath) -> ReleaseInCollection {
        let release: ReleaseInCollection
        switch myCollection {
        case .collection: release = collectionPagableManager.objects[indexPath.row]
        case .wanted: release = wantedPagableManager.objects[indexPath.row]
        case .trade: release = tradePagableManager.objects[indexPath.row]
        }
        
        return release
    }
    
    private func takeAction(forReleaseAt indexPath: IndexPath) {
        let release = getRelease(for: indexPath)
        
        let alert = UIAlertController(title: release.titleAndTypeAttributedString.string, message: release.bandsAttributedString.string, preferredStyle: .actionSheet)
        
        let releaseAction = UIAlertAction(title: "💿 View release", style: .default) { [unowned self] _ in
            self.pushReleaseDetailViewController(urlString: release.urlString, animated: true)
        }
        alert.addAction(releaseAction)
        
        release.bands.forEach { (eachBand) in
            let bandAction = UIAlertAction(title: "👥 Band: \(eachBand.name)", style: .default) { [unowned self] _ in
                self.pushBandDetailViewController(urlString: eachBand.urlString, animated: true)
            }
            alert.addAction(bandAction)
        }
        
        let changeVersionAction = UIAlertAction(title: "📄 Change version", style: .default) { [unowned self] _ in
            self.presentChangeVersionAlert(forReleaseAt: indexPath)
        }
        alert.addAction(changeVersionAction)
        
        let editNoteAction = UIAlertAction(title: "📝 Edit note", style: .default) { [unowned self] _ in
            self.editNote(for: release, at: indexPath)
        }
        alert.addAction(editNoteAction)
        
        let removeAction = UIAlertAction(title: "🗑️ Remove from collection", style: .destructive) { [unowned self] _ in
            self.remove(releaseInCollection: release, at: indexPath)
        }
        alert.addAction(removeAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentChangeVersionAlert(forReleaseAt indexPath: IndexPath) {
        let release = getRelease(for: indexPath)
        MBProgressHUD.showAdded(to: view, animated: true)
        RequestHelper.Collection.getVersionList(id: release.versionListId) { [weak self] (releaseVersions) in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let releaseVersions = releaseVersions {
                let alert = UIAlertController(title: "Change version", message: release.release.title, preferredStyle: .actionSheet)
                
                releaseVersions.forEach { (eachVersion) in
                    let versionAction = UIAlertAction(title: eachVersion.version, style: .default) { [unowned self] _ in
                        self.changeVersion(forReleaseAt: indexPath, newVersion: eachVersion)
                    }
                    alert.addAction(versionAction)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                Toast.displayMessageShortly("Error fetching versions")
            }
        }
    }
    
    private func changeVersion(forReleaseAt indexPath: IndexPath, newVersion: ReleaseVersion) {
        let release = getRelease(for: indexPath)
        MBProgressHUD.showAdded(to: view, animated: true)
        RequestHelper.Collection.changeVersion(collection: myCollection, release: release, versionId: newVersion.id) { [weak self] (isSuccessful) in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if isSuccessful {
                
                switch self.myCollection {
                case .collection: self.collectionPagableManager.objects[indexPath.row].updateVersion(newVersion.version)
                case .wanted:
                    self.wantedPagableManager.objects[indexPath.row].updateVersion(newVersion.version)
                case .trade:
                    self.tradePagableManager.objects[indexPath.row].updateVersion(newVersion.version)
                }
                
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                Toast.displayMessageShortly("Changed version")
            } else {
                Toast.displayMessageShortly("Error changing version. Please try again later.")
            }
        }
    }
    
    private func editNote(for releaseInCollection: ReleaseInCollection, at indexPath: IndexPath) {
        
    }
    
    private func remove(releaseInCollection: ReleaseInCollection, at indexPath: IndexPath) {
        
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension MyCollectionViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - PagableManagerDelegate
extension MyCollectionViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        showHUD()
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        Toast.displayMessageShortly(errorLoadingMessage)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        endRefreshing()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension MyCollectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        takeAction(forReleaseAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch myCollection {
        case .collection:
            if collectionPagableManager.moreToLoad && indexPath.row == collectionPagableManager.objects.count {
                collectionPagableManager.fetch()
            }
            return
            
        case .wanted:
            if wantedPagableManager.moreToLoad && indexPath.row == wantedPagableManager.objects.count {
                wantedPagableManager.fetch()
            }
            return
            
        case .trade:
            if tradePagableManager.moreToLoad && indexPath.row == tradePagableManager.objects.count {
                tradePagableManager.fetch()
            }
            return
        }
    }
}

// MARK: - UITableViewDataSource
extension MyCollectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let moreToLoad: Bool
        let count: Int
        switch myCollection {
        case .collection:
            guard let manager = collectionPagableManager else { return 0 }
            moreToLoad = manager.moreToLoad
            count = manager.objects.count
            
        case .wanted:
            guard let manager = wantedPagableManager else { return 0 }
            moreToLoad = manager.moreToLoad
            count = manager.objects.count

        case .trade:
            guard let manager = tradePagableManager else { return 0 }
            moreToLoad = manager.moreToLoad
            count = manager.objects.count
        }
        
        if moreToLoad {
            if count == 0 {
                return 0
            }
            
            return count + 1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Display loading cell if applicable
        let shouldDisplayLoadingCell: Bool
        switch myCollection {
        case .collection:
            shouldDisplayLoadingCell = collectionPagableManager.moreToLoad && indexPath.row == collectionPagableManager.objects.count
            
        case .wanted:
            shouldDisplayLoadingCell = wantedPagableManager.moreToLoad && indexPath.row == wantedPagableManager.objects.count
            
        case .trade:
            shouldDisplayLoadingCell = tradePagableManager.moreToLoad && indexPath.row == tradePagableManager.objects.count
        }
        
        if shouldDisplayLoadingCell {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        // Display normal cells
        let release = getRelease(for: indexPath)

        let cell = ReleaseInCollectionTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.fill(with: release)
        cell.tappedThumbnailImageView = { [unowned self] in
            self.presentPhotoViewerWithCacheChecking(photoUrlString: release.imageURLString, description: release.release.title, fromImageView: cell.thumbnailImageView)
        }
        return cell
    }
}
