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
    
    // Collection
    private var collectionPagableManager: PagableManager<ReleaseInCollection>!
    
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
        case .wanted: break
        case .trade: break
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
            collectionPagableManager = PagableManager<ReleaseInCollection>()
            collectionPagableManager.delegate = self
            
        case .wanted: break
        case .trade: break
        }
    }
    
    override func refresh() {
        switch myCollection {
        case .collection:
            collectionPagableManager.reset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.collectionPagableManager.fetch()
            }
            
        case .wanted: break
        case .trade: break
        }
        
        tableView.reloadData()
    }
}

// MARK: - View details & Edit note
extension MyCollectionViewController {
//    private func takeActionForBandBookmark(at indexPath: IndexPath) {
//        let bandBookmark = bandBookmarkPagableManager.objects[indexPath.row]
//
//        let alert = UIAlertController(title: bandBookmark.name, message: "\(bandBookmark.country.name) | \(bandBookmark.genre)", preferredStyle: .actionSheet)
//
//        let viewAction = UIAlertAction(title: "View band", style: .default) { [unowned self] _ in
//            self.pushBandDetailViewController(urlString: bandBookmark.urlString, animated: true)
//        }
//        alert.addAction(viewAction)
//
//        let editAction = UIAlertAction(title: "Edit note", style: .default) { [unowned self] _ in
//            self.presentEditNoteAlert(editId: bandBookmark.editId, oldNote: bandBookmark.note, indexPath: indexPath)
//        }
//        alert.addAction(editAction)
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//    }
//
//    private func presentEditNoteAlert(editId: String, oldNote: String?, indexPath: IndexPath) {
//        let alert = UIAlertController(title: "Edit note", message: "⚠️ Note can not contain emoji", preferredStyle: .alert)
//
//        alert.addTextField { (noteTextField) in
//            noteTextField.placeholder = "Add note"
//            noteTextField.returnKeyType = .done
//            noteTextField.clearButtonMode = .whileEditing
//            noteTextField.text = oldNote
//        }
//
//        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
//            self.updateNote(editId: editId, newNote: alert.textFields?[0].text, indexPath: indexPath)
//        }
//        alert.addAction(saveAction)
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//    }
//
//    private func updateNote(editId: String, newNote: String?, indexPath: IndexPath) {
//        MBProgressHUD.showAdded(to: view, animated: true)
//
//        RequestHelper.Bookmark.updateNote(editId: editId, newNote: newNote) { [weak self] (isSuccess) in
//            guard let self = self else { return }
//            MBProgressHUD.hide(for: self.view, animated: true)
//
//            if isSuccess {
//                switch self.myBookmark {
//                case .bands: self.bandBookmarkPagableManager.objects[indexPath.row].updateNote(newNote)
//                case .artists: self.artistBookmarkPagableManager.objects[indexPath.row].updateNote(newNote)
//                case .labels: self.labelBookmarkPagableManager.objects[indexPath.row].updateNote(newNote)
//                case .releases: self.releaseBookmarkPagableManager.objects[indexPath.row].updateNote(newNote)
//                }
//
//                self.tableView.reloadRows(at: [indexPath], with: .automatic)
//                Toast.displayMessageShortly("Updated note")
//            } else {
//                Toast.displayMessageShortly("Error saving note. Please try again later.")
//            }
//        }
//    }
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
        
        switch myCollection {
        case .collection: break
        case .wanted: break
        case .trade: break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch myCollection {
        case .collection:
            if collectionPagableManager.moreToLoad && indexPath.row == collectionPagableManager.objects.count {
                collectionPagableManager.fetch()
            }
            return
            
        case .wanted: return
        case .trade: return
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
            moreToLoad = false
            count = 0

        case .trade:
            moreToLoad = false
            count = 0
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
            
        case .wanted: shouldDisplayLoadingCell = false
        case .trade: shouldDisplayLoadingCell = false
        }
        
        if shouldDisplayLoadingCell {
            let loadingCell = LoadingTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            loadingCell.displayIsLoading()
            return loadingCell
        }
        
        // Display normal cells
        switch myCollection {
        case .collection:
            let cell = ReleaseInCollectionTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
            let release = collectionPagableManager.objects[indexPath.row]
            cell.fill(with: release)
            cell.tappedThumbnailImageView = { [unowned self] in
                self.presentPhotoViewerWithCacheChecking(photoUrlString: release.imageURLString, description: release.release.title, fromImageView: cell.thumbnailImageView)
            }
            return cell
            
        case .wanted: return UITableViewCell()
        case .trade: return UITableViewCell()
        }
    }
}
