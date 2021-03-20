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
import MaterialComponents.MaterialSnackbar
import FirebaseAnalytics

final class MyCollectionViewController: RefreshableViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    
    var myProfile: UserProfile!
    var myCollection: MyCollection = .collection
    
    private var collectionPagableManager: PagableManager<ReleaseCollection>!
    private var wantedPagableManager: PagableManager<ReleaseWanted>!
    private var tradePagableManager: PagableManager<ReleaseTrade>!
    
    private var lastDeletedRelease: ReleaseInCollection? = nil
    private var lastDeletedReleaseIndexPath: IndexPath? = nil
    
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
        let options = ["<USER_ID>": myProfile.id!]
        switch myCollection {
        case .collection:
            collectionPagableManager = PagableManager<ReleaseCollection>(options: options)
            collectionPagableManager.delegate = self
            
        case .wanted:
            wantedPagableManager = PagableManager<ReleaseWanted>(options: options)
            wantedPagableManager.delegate = self
            
        case .trade:
            tradePagableManager = PagableManager<ReleaseTrade>(options: options)
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
        
        let style: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        
        let alert = UIAlertController(title: release.bandsAttributedString.string, message: "\(release.titleAndTypeAttributedString.string)\n\(release.version)", preferredStyle: style)
        
        // View Release
        let releaseAction = UIAlertAction(title: "💿 View release", style: .default) { [unowned self] _ in
            self.pushReleaseDetailViewController(urlString: release.urlString, animated: true)
            Analytics.logEvent("view_collection_release", parameters: nil)
        }
        alert.addAction(releaseAction)
        
        // View bands
        release.bands.forEach { (eachBand) in
            let bandAction = UIAlertAction(title: "👥 Band: \(eachBand.name)", style: .default) { [unowned self] _ in
                self.pushBandDetailViewController(urlString: eachBand.urlString, animated: true)
                Analytics.logEvent("view_collectionband", parameters: nil)
            }
            alert.addAction(bandAction)
        }
        
        // Change version
        let changeVersionAction = UIAlertAction(title: "📄 Change version", style: .default) { [unowned self] _ in
            self.presentChangeVersionAlert(forReleaseAt: indexPath)
        }
        alert.addAction(changeVersionAction)
        
        // Edit note
        let editNoteAction = UIAlertAction(title: "📝 Edit note", style: .default) { [unowned self] _ in
            self.presentEditNoteAlert(forReleaseAt: indexPath)
        }
        alert.addAction(editNoteAction)
        
        // Move to other collection
        let moveToCollectionAction = UIAlertAction(title: "🔄 Move to collection", style: .default) { [unowned self] _ in
            self.move(releaseAt: indexPath, to: .collection)
        }
        
        let moveToWantedListAction = UIAlertAction(title: "🔄 Move to wanted list", style: .default) { [unowned self] _ in
            self.move(releaseAt: indexPath, to: .wanted)
        }
        
        let moveToTradeListAction = UIAlertAction(title: "🔄 Move to trade list", style: .default) { [unowned self] _ in
            self.move(releaseAt: indexPath, to: .trade)
        }
        
        switch myCollection {
        case .collection:
            alert.addAction(moveToWantedListAction)
            alert.addAction(moveToTradeListAction)
            
        case .wanted:
            alert.addAction(moveToCollectionAction)
            alert.addAction(moveToTradeListAction)
            
        case .trade:
            alert.addAction(moveToCollectionAction)
            alert.addAction(moveToWantedListAction)
        }
        
        // Remove
        let removeAction = UIAlertAction(title: "🗑️ Remove from collection", style: .destructive) { [unowned self] _ in
            self.remove(releaseAt: indexPath)
        }
        alert.addAction(removeAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentChangeVersionAlert(forReleaseAt indexPath: IndexPath) {
        let release = getRelease(for: indexPath)
        MBProgressHUD.showAdded(to: view, animated: true)
        RequestService.Collection.getVersionList(id: release.versionListId) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(let releaseVersions):
                let style: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
                
                let alert = UIAlertController(title: "Change version", message: release.release.title, preferredStyle: style)
                
                releaseVersions.forEach { (eachVersion) in
                    let versionAction = UIAlertAction(title: eachVersion.version, style: .default) { [unowned self] _ in
                        self.changeVersion(forReleaseAt: indexPath, newVersion: eachVersion)
                    }
                    alert.addAction(versionAction)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
                Analytics.logEvent("collection_fetch_versions_error", parameters: nil)
            }
        }
    }
    
    private func changeVersion(forReleaseAt indexPath: IndexPath, newVersion: ReleaseVersion) {
        let release = getRelease(for: indexPath)
        MBProgressHUD.showAdded(to: view, animated: true)
        RequestService.Collection.changeVersion(collection: myCollection, release: release, versionId: newVersion.id) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(_):
                switch self.myCollection {
                case .collection: self.collectionPagableManager.objects[indexPath.row].updateVersion(newVersion.version)
                case .wanted:
                    self.wantedPagableManager.objects[indexPath.row].updateVersion(newVersion.version)
                case .trade:
                    self.tradePagableManager.objects[indexPath.row].updateVersion(newVersion.version)
                }
                
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                Toast.displayMessageShortly("Changed version")
                Analytics.logEvent("collection_change_version_success", parameters: nil)
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
                Analytics.logEvent("collection_change_version_error", parameters: nil)
            }
        }
    }
    
    private func presentEditNoteAlert(forReleaseAt indexPath: IndexPath) {
        let release = getRelease(for: indexPath)
        let alert = UIAlertController(title: "Edit note", message: "⚠️ Note can not contain emoji", preferredStyle: .alert)
        
        alert.addTextField { (noteTextField) in
            noteTextField.placeholder = "Add note"
            noteTextField.returnKeyType = .done
            noteTextField.clearButtonMode = .whileEditing
            noteTextField.text = release.note
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            self.updateNote(forReleaseAt: indexPath, newNote: alert.textFields?[0].text)
        }
        alert.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func updateNote(forReleaseAt indexPath: IndexPath, newNote: String?) {
        let release = getRelease(for: indexPath)
        MBProgressHUD.showAdded(to: view, animated: true)
        
        RequestService.Collection.updateNote(collection: myCollection, release: release, newNote: newNote) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(_):
                switch self.myCollection {
                case .collection: self.collectionPagableManager.objects[indexPath.row].updateNote(newNote)
                case .wanted:
                    self.wantedPagableManager.objects[indexPath.row].updateNote(newNote)
                case .trade:
                    self.tradePagableManager.objects[indexPath.row].updateNote(newNote)
                }
                
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                Toast.displayMessageShortly("Saved note")
                Analytics.logEvent("collection_update_note_success", parameters: nil)
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
                Analytics.logEvent("collection~_update_note_error", parameters: nil)
            }
        }
    }
    
    private func remove(releaseAt indexPath: IndexPath) {
        let release = getRelease(for: indexPath)
        MBProgressHUD.showAdded(to: view, animated: true)
        RequestService.Collection.remove(release: release, from: myCollection) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(_):
                self.lastDeletedReleaseIndexPath = indexPath
                
                self.tableView.performBatchUpdates({
                    switch self.myCollection {
                    case .collection:
                        self.lastDeletedRelease = self.collectionPagableManager.objects[indexPath.row]
                        self.collectionPagableManager.removeObject(at: indexPath.row)
                        
                    case .wanted:
                        self.lastDeletedRelease = self.wantedPagableManager.objects[indexPath.row]
                        self.wantedPagableManager.removeObject(at: indexPath.row)
                        
                    case .trade:
                        self.lastDeletedRelease = self.tradePagableManager.objects[indexPath.row]
                        self.tradePagableManager.removeObject(at: indexPath.row)
                    }
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }) { _ in
                    self.displayUndoSnackbar()
                }
                Analytics.logEvent("collection_remove_success", parameters: nil)
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
                Analytics.logEvent("collection_remove_error", parameters: nil)
            }
        }
    }
    
    private func displayUndoSnackbar() {
        guard let lastDeletedRelease = lastDeletedRelease else { return }
        let message = MDCSnackbarMessage()
        message.text = "\"\(lastDeletedRelease.release.title)\" removed from \(myCollection.listDescription)"
        let action = MDCSnackbarMessageAction()
        action.handler = { [unowned self] () in
            self.undoLastRemoval()
        }
        action.title = "Undo"
        message.action = action
        MDCSnackbarManager().show(message)
    }
    
    private func undoLastRemoval() {
        guard let lastDeletedRelease = lastDeletedRelease, let lastDeletedReleaseIndexPath = lastDeletedReleaseIndexPath else { return }

        MBProgressHUD.showAdded(to: view, animated: true)
        
        RequestService.Collection.add(releaseId: lastDeletedRelease.id, to: myCollection) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(_):
                self.tableView.performBatchUpdates({
                    switch self.myCollection {
                    case .collection:
                        self.collectionPagableManager.insertObject(lastDeletedRelease as! ReleaseCollection, at: lastDeletedReleaseIndexPath.row)

                    case .wanted:
                        self.wantedPagableManager.insertObject(lastDeletedRelease as! ReleaseWanted, at: lastDeletedReleaseIndexPath.row)
                        
                    case .trade:
                        self.tradePagableManager.insertObject(lastDeletedRelease as! ReleaseTrade, at: lastDeletedReleaseIndexPath.row)
                    }

                    self.tableView.insertRows(at: [lastDeletedReleaseIndexPath], with: .automatic)
                })
                Analytics.logEvent("collection_undo_removal_success", parameters: nil)
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
                Analytics.logEvent("collection_undo_removal_error", parameters: nil)
            }
        }
    }
    
    private func move(releaseAt indexPath: IndexPath, to toCollection: MyCollection) {
        let release = getRelease(for: indexPath)
        MBProgressHUD.showAdded(to: view, animated: true)
        
        RequestService.Collection.move(release: release, from: myCollection, to: toCollection) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(_):
                self.tableView.performBatchUpdates({
                    switch self.myCollection {
                    case .collection: self.collectionPagableManager.removeObject(at: indexPath.row)
                    case .wanted: self.wantedPagableManager.removeObject(at: indexPath.row)
                    case .trade: self.tradePagableManager.removeObject(at: indexPath.row)
                    }
                    
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                })
                Analytics.logEvent("collection_move_success", parameters: nil)
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
                Analytics.logEvent("collection_move_error", parameters: nil)
            }
        }
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
        
        if pagableManager.objects.count == 0 {
            let message: String
            switch myCollection {
            case .collection: message = "You haven't added anything to collection"
            case .wanted: message = "You haven't added anything to wanted list"
            case .trade: message = "You haven't added anything to trade list"
            }
            Toast.displayMessageShortly(message)
        }
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
