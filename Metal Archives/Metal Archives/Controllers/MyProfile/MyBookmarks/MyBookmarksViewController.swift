//
//  MyBookmarksViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 10/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import Toaster
import Alamofire
import MBProgressHUD
import MaterialComponents.MaterialSnackbar
import FirebaseAnalytics

final class MyBookmarksViewController: RefreshableViewController {
    @IBOutlet private weak var simpleNavigationBarView: SimpleNavigationBarView!
    
    var myBookmark: MyBookmark = .bands
    
    // Band
    private var bandBookmarkPagableManager: PagableManager<BandBookmark>!
    private var bandBookmarkOrder: BandOrReleaseBookmarkOrder = .lastModifiedDescending
    
    // Release
    private var releaseBookmarkPagableManager: PagableManager<ReleaseBookmark>!
    private var releaseBookmarkOrder: BandOrReleaseBookmarkOrder = .lastModifiedDescending
    
    // Artist
    private var artistBookmarkPagableManager: PagableManager<ArtistBookmark>!
    private var artistBookmarkOrder: ArtistOrLabelBookmarkOrder = .lastModifiedDescending
    
    // Label
    private var labelBookmarkPagableManager: PagableManager<LabelBookmark>!
    private var labelBookmarkOrder: ArtistOrLabelBookmarkOrder = .lastModifiedDescending
    
    private var lastDeletedObject: Any? = nil
    private var lastDeletedObjectIndexPath: IndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        handleSimpleNavigationBarViewActions()
        setUpTableView()
        initPagableManagers()
        
        switch myBookmark {
        case .bands: bandBookmarkPagableManager.fetch()
        case .artists: artistBookmarkPagableManager.fetch()
        case .labels: labelBookmarkPagableManager.fetch()
        case .releases: releaseBookmarkPagableManager.fetch()
        }
    }
    
    private func handleSimpleNavigationBarViewActions() {
        simpleNavigationBarView.setAlphaForBackgroundAndTitleLabel(1)
        simpleNavigationBarView.setTitle(myBookmark.description)
        
        simpleNavigationBarView.didTapLeftButton = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        simpleNavigationBarView.setRightButtonIcon(#imageLiteral(resourceName: "sort"))
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            switch self.myBookmark {
            case .bands: self.displayBandOrReleaseBookmarkOrderViewController(type: .band)
            case .artists: self.displayArtistOrLabelBookmarkOrderViewController(type: .artist)
            case .labels: self.displayArtistOrLabelBookmarkOrderViewController(type: .label)
            case .releases: self.displayBandOrReleaseBookmarkOrderViewController(type: .release)
            }
        }
    }
    
    private func setUpTableView() {
        LoadingTableViewCell.register(with: tableView)
        BandBookmarkTableViewCell.register(with: tableView)
        ReleaseBookmarkTableViewCell.register(with: tableView)
        ArtistBookmarkTableViewCell.register(with: tableView)
        LabelBookmarkTableViewCell.register(with: tableView)
    }
    
    private func initPagableManagers() {
        switch myBookmark {
        case .bands:
            bandBookmarkPagableManager = PagableManager<BandBookmark>(options: bandBookmarkOrder.options)
            bandBookmarkPagableManager.delegate = self
            
        case .artists:
            artistBookmarkPagableManager = PagableManager<ArtistBookmark>(options: artistBookmarkOrder.options)
            artistBookmarkPagableManager.delegate = self
            
        case .labels:
            labelBookmarkPagableManager = PagableManager<LabelBookmark>(options: labelBookmarkOrder.options)
            labelBookmarkPagableManager.delegate = self
            
        case .releases:
            releaseBookmarkPagableManager = PagableManager<ReleaseBookmark>(options: releaseBookmarkOrder.options)
            releaseBookmarkPagableManager.delegate = self
        }
    }
    
    override func refresh() {
        switch myBookmark {
        case .bands:
            bandBookmarkPagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.bandBookmarkPagableManager.fetch()
            }
            
        case .artists:
            artistBookmarkPagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.artistBookmarkPagableManager.fetch()
            }
            
        case .labels:
            labelBookmarkPagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.labelBookmarkPagableManager.fetch()
            }
            
        case .releases:
            releaseBookmarkPagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.releaseBookmarkPagableManager.fetch()
            }
        }
        
        tableView.reloadData()
        Analytics.logEvent("bookmark_refresh", parameters: nil)
    }
}

// MARK: - View details & Edit note & Remove
extension MyBookmarksViewController {
    private func takeActionForBandBookmark(at indexPath: IndexPath) {
        let bandBookmark = bandBookmarkPagableManager.objects[indexPath.row]
        
        let style: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        
        let alert = UIAlertController(title: bandBookmark.name, message: "\(bandBookmark.country.name) | \(bandBookmark.genre)", preferredStyle: style)
        
        let viewAction = UIAlertAction(title: "👥 View band", style: .default) { [unowned self] _ in
            self.pushBandDetailViewController(urlString: bandBookmark.urlString, animated: true)
            Analytics.logEvent("bookmark_view_band", parameters: nil)
        }
        alert.addAction(viewAction)
        
        let editAction = UIAlertAction(title: "📝 Edit note", style: .default) { [unowned self] _ in
            self.presentEditNoteAlert(editId: bandBookmark.editId, oldNote: bandBookmark.note, indexPath: indexPath)
        }
        alert.addAction(editAction)
        
        let removeAction = UIAlertAction(title: "🗑️ Remove from bookmark", style: .destructive) { [unowned self] _ in
            self.remove(id: bandBookmark.id, at: indexPath)
        }
        alert.addAction(removeAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func takeActionForArtistBookmark(at indexPath: IndexPath) {
        let artistBookmark = artistBookmarkPagableManager.objects[indexPath.row]
        
        let style: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        
        let alert = UIAlertController(title: artistBookmark.name, message: artistBookmark.country.name, preferredStyle: style)
        
        let viewAction = UIAlertAction(title: "👤 View artist", style: .default) { [unowned self] _ in
            self.pushArtistDetailViewController(urlString: artistBookmark.urlString, animated: true)
            Analytics.logEvent("bookmark_view_artist", parameters: nil)
        }
        alert.addAction(viewAction)
        
        let editAction = UIAlertAction(title: "📝 Edit note", style: .default) { [unowned self] _ in
            self.presentEditNoteAlert(editId: artistBookmark.editId, oldNote: artistBookmark.note, indexPath: indexPath)
        }
        alert.addAction(editAction)
        
        let removeAction = UIAlertAction(title: "🗑️ Remove from bookmark", style: .destructive) { [unowned self] _ in
            self.remove(id: artistBookmark.id, at: indexPath)
        }
        alert.addAction(removeAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func takeActionForLabelBookmark(at indexPath: IndexPath) {
        let labelBookmark = labelBookmarkPagableManager.objects[indexPath.row]
        
        let style: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        
        let alert = UIAlertController(title: labelBookmark.name, message: labelBookmark.country.name, preferredStyle: style)
        
        let viewAction = UIAlertAction(title: "🏷️ View label", style: .default) { [unowned self] _ in
            self.pushLabelDetailViewController(urlString: labelBookmark.urlString, animated: true)
            Analytics.logEvent("bookmark_view_label", parameters: nil)
        }
        alert.addAction(viewAction)
        
        let editAction = UIAlertAction(title: "📝 Edit note", style: .default) { [unowned self] _ in
            self.presentEditNoteAlert(editId: labelBookmark.editId, oldNote: labelBookmark.note, indexPath: indexPath)
        }
        alert.addAction(editAction)
        
        let removeAction = UIAlertAction(title: "🗑️ Remove from bookmark", style: .destructive) { [unowned self] _ in
            self.remove(id: labelBookmark.id, at: indexPath)
        }
        alert.addAction(removeAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func takeActionForReleaseBookmark(at indexPath: IndexPath) {
        let releaseBookmark = releaseBookmarkPagableManager.objects[indexPath.row]
        
        let style: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        
        let alert = UIAlertController(title: releaseBookmark.title, message: "\(releaseBookmark.bandName) | \(releaseBookmark.country.name) | \(releaseBookmark.genre)", preferredStyle: style)
        
        let viewAction = UIAlertAction(title: "💿 View release", style: .default) { [unowned self] _ in
            self.pushReleaseDetailViewController(urlString: releaseBookmark.urlString, animated: true)
            Analytics.logEvent("bookmark_view_release", parameters: nil)
        }
        alert.addAction(viewAction)
        
        let editAction = UIAlertAction(title: "📝 Edit note", style: .default) { [unowned self] _ in
            self.presentEditNoteAlert(editId: releaseBookmark.editId, oldNote: releaseBookmark.note, indexPath: indexPath)
        }
        alert.addAction(editAction)
        
        let removeAction = UIAlertAction(title: "🗑️ Remove from bookmark", style: .destructive) { [unowned self] _ in
            self.remove(id: releaseBookmark.id, at: indexPath)
        }
        alert.addAction(removeAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentEditNoteAlert(editId: String, oldNote: String?, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit note", message: "⚠️ Note can not contain emoji", preferredStyle: .alert)
        
        alert.addTextField { (noteTextField) in
            noteTextField.placeholder = "Add note"
            noteTextField.returnKeyType = .done
            noteTextField.clearButtonMode = .whileEditing
            noteTextField.text = oldNote
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            self.updateNote(editId: editId, newNote: alert.textFields?[0].text, indexPath: indexPath)
        }
        alert.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func updateNote(editId: String, newNote: String?, indexPath: IndexPath) {
        MBProgressHUD.showAdded(to: view, animated: true)
        
        RequestService.Bookmark.updateNote(editId: editId, newNote: newNote) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(_):
                switch self.myBookmark {
                case .bands: self.bandBookmarkPagableManager.objects[indexPath.row].updateNote(newNote)
                case .artists: self.artistBookmarkPagableManager.objects[indexPath.row].updateNote(newNote)
                case .labels: self.labelBookmarkPagableManager.objects[indexPath.row].updateNote(newNote)
                case .releases: self.releaseBookmarkPagableManager.objects[indexPath.row].updateNote(newNote)
                }
                
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                Toast.displayMessageShortly("Saved note")
                Analytics.logEvent("bookmark_edit_note_success", parameters: nil)
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
                Analytics.logEvent("bookmark_edit_note_error", parameters: nil)
            }
        }
    }
    
    private func remove(id: String, at indexPath: IndexPath) {
        MBProgressHUD.showAdded(to: view, animated: true)
        RequestService.Bookmark.bookmark(id: id, action: .remove, type: myBookmark) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(_):
                self.lastDeletedObjectIndexPath = indexPath
                
                self.tableView.performBatchUpdates({
                    switch self.myBookmark {
                    case .bands:
                        self.lastDeletedObject = self.bandBookmarkPagableManager.objects[indexPath.row]
                        self.bandBookmarkPagableManager.removeObject(at: indexPath.row)
                        
                    case .artists:
                        self.lastDeletedObject = self.artistBookmarkPagableManager.objects[indexPath.row]
                        self.artistBookmarkPagableManager.removeObject(at: indexPath.row)
                        
                    case .labels:
                        self.lastDeletedObject = self.labelBookmarkPagableManager.objects[indexPath.row]
                        self.labelBookmarkPagableManager.removeObject(at: indexPath.row)
                        
                    case .releases:
                        self.lastDeletedObject = self.releaseBookmarkPagableManager.objects[indexPath.row]
                        self.releaseBookmarkPagableManager.removeObject(at: indexPath.row)
                    }
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }) { _ in
                    self.displayUndoSnackbar()
                }
                Analytics.logEvent("bookmark_remove_success", parameters: nil)
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
                Analytics.logEvent("bookmark_remove_error", parameters: nil)
            }
        }
    }
    
    private func displayUndoSnackbar() {
        let objectName: String
        switch myBookmark {
        case .bands: objectName = (lastDeletedObject as! BandBookmark).name
        case .artists: objectName = (lastDeletedObject as! ArtistBookmark).name
        case .labels: objectName = (lastDeletedObject as! LabelBookmark).name
        case .releases: objectName = (lastDeletedObject as! ReleaseBookmark).title
        }
        
        let message = MDCSnackbarMessage()
        message.text = "\"\(objectName)\" removed from \(myBookmark.shortDescription) bookmarks"
        let action = MDCSnackbarMessageAction()
        action.handler = { [unowned self] () in
            self.undoLastRemoval()
        }
        action.title = "Undo"
        message.action = action
        MDCSnackbarManager().show(message)
    }
    
    private func undoLastRemoval() {
        guard let lastDeletedObject = lastDeletedObject, let lastDeletedObjectIndexPath = lastDeletedObjectIndexPath else { return }
        
        let id: String
        switch myBookmark {
        case .bands: id = (lastDeletedObject as! BandBookmark).id
        case .artists: id = (lastDeletedObject as! ArtistBookmark).id
        case .labels: id = (lastDeletedObject as! LabelBookmark).id
        case .releases: id = (lastDeletedObject as! ReleaseBookmark).id
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        RequestService.Bookmark.bookmark(id: id, action: .add, type: myBookmark) { [weak self] result in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch result {
            case .success(_):
                self.tableView.performBatchUpdates({
                    switch self.myBookmark {
                    case .bands:
                        self.bandBookmarkPagableManager.insertObject(lastDeletedObject as! BandBookmark, at: lastDeletedObjectIndexPath.row)
                        
                    case .artists:
                        self.artistBookmarkPagableManager.insertObject(lastDeletedObject as! ArtistBookmark, at: lastDeletedObjectIndexPath.row)
                        
                    case .labels:
                        self.labelBookmarkPagableManager.insertObject(lastDeletedObject as! LabelBookmark, at: lastDeletedObjectIndexPath.row)
                        
                    case .releases:
                        self.releaseBookmarkPagableManager.insertObject(lastDeletedObject as! ReleaseBookmark, at: lastDeletedObjectIndexPath.row)
                    }
                    
                    self.tableView.insertRows(at: [lastDeletedObjectIndexPath], with: .automatic)
                })
                Analytics.logEvent("bookmark_undo_removal_success", parameters: nil)
                
            case .failure(let error):
                Toast.displayMessageShortly(error.localizedDescription)
                Analytics.logEvent("bookmark_undo_removal_error", parameters: nil)
            }
        }
    }
}

// MARK: - Popover
extension MyBookmarksViewController {
    private func displayBandOrReleaseBookmarkOrderViewController(type: BandOrReleaseBookmarkOrderViewController.BookmarkType) {
        let bandOrReleaseBookmarkOrderViewController = UIStoryboard(name: "MyProfile", bundle: nil).instantiateViewController(withIdentifier: "BandOrReleaseBookmarkOrderViewController") as! BandOrReleaseBookmarkOrderViewController
        
        switch type {
        case .band:
            bandOrReleaseBookmarkOrderViewController.currentOrder = bandBookmarkOrder
            Analytics.logEvent("bookmark_reorder_bands", parameters: nil)
            
        case .release:
            bandOrReleaseBookmarkOrderViewController.currentOrder = releaseBookmarkOrder
            Analytics.logEvent("bookmark_reorder_release", parameters: nil)
        }
        
        bandOrReleaseBookmarkOrderViewController.modalPresentationStyle = .popover
        bandOrReleaseBookmarkOrderViewController.popoverPresentationController?.permittedArrowDirections = .any
        
        bandOrReleaseBookmarkOrderViewController.popoverPresentationController?.delegate = self
        bandOrReleaseBookmarkOrderViewController.popoverPresentationController?.sourceView = view
    
        bandOrReleaseBookmarkOrderViewController.popoverPresentationController?.sourceRect = simpleNavigationBarView.rightButton.frame
        
        bandOrReleaseBookmarkOrderViewController.selectedBandOrReleaseBookmarkOrder = { [unowned self] (bandOrReleaseBookmarkOrder) in
            switch type {
            case .band: self.bandBookmarkOrder = bandOrReleaseBookmarkOrder
            case .release: self.releaseBookmarkOrder = bandOrReleaseBookmarkOrder
            }
            
            self.initPagableManagers()
            self.refresh()
        }
        
        present(bandOrReleaseBookmarkOrderViewController, animated: true, completion: nil)
    }
    
    private func displayArtistOrLabelBookmarkOrderViewController(type: ArtistOrLabelBookmarkOrderViewController.BookmarkType) {
        let artistOrLabelBookmarkOrderViewController = UIStoryboard(name: "MyProfile", bundle: nil).instantiateViewController(withIdentifier: "ArtistOrLabelBookmarkOrderViewController") as! ArtistOrLabelBookmarkOrderViewController
        
        switch type {
        case .artist:
            artistOrLabelBookmarkOrderViewController.currentOrder = artistBookmarkOrder
            Analytics.logEvent("bookmark_reorder_artists", parameters: nil)
            
        case .label:
            artistOrLabelBookmarkOrderViewController.currentOrder = labelBookmarkOrder
            Analytics.logEvent("bookmark_reorder_labels", parameters: nil)
        }
        
        artistOrLabelBookmarkOrderViewController.modalPresentationStyle = .popover
        artistOrLabelBookmarkOrderViewController.popoverPresentationController?.permittedArrowDirections = .any
        
        artistOrLabelBookmarkOrderViewController.popoverPresentationController?.delegate = self
        artistOrLabelBookmarkOrderViewController.popoverPresentationController?.sourceView = view
    
        artistOrLabelBookmarkOrderViewController.popoverPresentationController?.sourceRect = simpleNavigationBarView.rightButton.frame
        
        artistOrLabelBookmarkOrderViewController.selectedArtistOrLabelBookmarkOrder = { [unowned self] (artistOrLabelBookmarkOrder) in
            switch type {
            case .artist: self.artistBookmarkOrder = artistOrLabelBookmarkOrder
            case .label: self.labelBookmarkOrder = artistOrLabelBookmarkOrder
            }
            
            self.initPagableManagers()
            self.refresh()
        }
        
        present(artistOrLabelBookmarkOrderViewController, animated: true, completion: nil)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension MyBookmarksViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - PagableManagerDelegate
extension MyBookmarksViewController: PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        showHUD()
    }
    
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        Toast.displayMessageShortly(errorLoadingMessage)
        Analytics.logEvent("bookmark_fetch_error", parameters: nil)
    }
    
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>) where T : Pagable {
        hideHUD()
        endRefreshing()
        tableView.reloadData()
        
        if pagableManager.objects.count == 0 {
            let message: String
            switch myBookmark {
            case .bands: message = "You haven't bookmarked any band"
            case .artists: message = "You haven't bookmarked any artist"
            case .labels: message = "You haven't bookmarked any label"
            case .releases: message = "You haven't bookmarked any release"
            }
            Toast.displayMessageShortly(message)
        }
    }
}

// MARK: - UITableViewDelegate
extension MyBookmarksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch myBookmark {
        case .bands: takeActionForBandBookmark(at: indexPath)
        case .artists: takeActionForArtistBookmark(at: indexPath)
        case .labels: takeActionForLabelBookmark(at: indexPath)
        case .releases: takeActionForReleaseBookmark(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch myBookmark {
        case .bands:
            if bandBookmarkPagableManager.moreToLoad && indexPath.row == bandBookmarkPagableManager.objects.count {
                bandBookmarkPagableManager.fetch()
                Analytics.logEvent("bookmark_fetch_more_bands", parameters: nil)
            }
            return
            
        case .artists:
            if artistBookmarkPagableManager.moreToLoad && indexPath.row == artistBookmarkPagableManager.objects.count {
                artistBookmarkPagableManager.fetch()
                Analytics.logEvent("bookmark_fetch_more_artists", parameters: nil)
            }
            return
            
        case .labels:
            if labelBookmarkPagableManager.moreToLoad && indexPath.row == labelBookmarkPagableManager.objects.count {
                labelBookmarkPagableManager.fetch()
                Analytics.logEvent("bookmark_fetch_more_labels", parameters: nil)
            }
            return
            
        case .releases:
            if releaseBookmarkPagableManager.moreToLoad && indexPath.row == releaseBookmarkPagableManager.objects.count {
                releaseBookmarkPagableManager.fetch()
                Analytics.logEvent("bookmark_fetch_more_releases", parameters: nil)
            }
            return
        }
    }
}

// MARK: - UITableViewDataSource
extension MyBookmarksViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let moreToLoad: Bool
        let count: Int
        switch myBookmark {
        case .bands:
            guard let manager = bandBookmarkPagableManager else { return 0 }
            moreToLoad = manager.moreToLoad
            count = manager.objects.count
            
        case .artists:
            guard let manager = artistBookmarkPagableManager else { return 0 }
            moreToLoad = manager.moreToLoad
            count = manager.objects.count
            
        case .labels:
            guard let manager = labelBookmarkPagableManager else { return 0 }
            moreToLoad = manager.moreToLoad
            count = manager.objects.count
            
        case .releases:
            guard let manager = releaseBookmarkPagableManager else { return 0 }
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
        switch myBookmark {
        case .bands:
            shouldDisplayLoadingCell = bandBookmarkPagableManager.moreToLoad && indexPath.row == bandBookmarkPagableManager.objects.count
            
        case .artists:
            shouldDisplayLoadingCell = artistBookmarkPagableManager.moreToLoad && indexPath.row == artistBookmarkPagableManager.objects.count
            
        case .labels:
            shouldDisplayLoadingCell = labelBookmarkPagableManager.moreToLoad && indexPath.row == labelBookmarkPagableManager.objects.count
            
        case .releases:
            shouldDisplayLoadingCell = releaseBookmarkPagableManager.moreToLoad && indexPath.row == releaseBookmarkPagableManager.objects.count
        }
        
        if shouldDisplayLoadingCell {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        // Display normal cells
        switch myBookmark {
        case .bands:
            let cell = BandBookmarkTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            let bandBookmark = bandBookmarkPagableManager.objects[indexPath.row]
            cell.fill(with: bandBookmark)
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: bandBookmark.imageURLString, description: bandBookmark.name, fromImageView: cell.thumbnailImageView)
            }
            return cell
            
        case .artists:
            let cell = ArtistBookmarkTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            let artistBookmark = artistBookmarkPagableManager.objects[indexPath.row]
            cell.fill(with: artistBookmark)
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: artistBookmark.imageURLString, description: artistBookmark.name, fromImageView: cell.thumbnailImageView)
            }
            return cell
            
        case .labels:
            let cell = LabelBookmarkTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            let labelBookmark = labelBookmarkPagableManager.objects[indexPath.row]
            cell.fill(with: labelBookmark)
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: labelBookmark.imageURLString, description: labelBookmark.name, fromImageView: cell.thumbnailImageView)
            }
            return cell
            
        case .releases:
            let cell = ReleaseBookmarkTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            let releaseBookmark = releaseBookmarkPagableManager.objects[indexPath.row]
            cell.fill(with: releaseBookmark)
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: releaseBookmark.imageURLString, description: releaseBookmark.title, fromImageView: cell.thumbnailImageView)
            }
            return cell
        }
    }
}
