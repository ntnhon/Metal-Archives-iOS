//
//  PagableManager.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

protocol PagableManagerDelegate: class {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>)
    func pagableManagerDidFailFetching<T>(_ pagableManager: PagableManager<T>)
    func pagableManagerDidFinishFetching<T>(_ pagableManager: PagableManager<T>)
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>)
}

extension PagableManagerDelegate {
    func pagableManagerDidBeginFetching<T>(_ pagableManager: PagableManager<T>) {
        //Empty default implementation to make function optional
    }
    
    func pagableManagerIsBeingBlocked<T>(_ pagableManager: PagableManager<T>) {
        //Empty default implementation to make function optional
    }
}

final class PagableManager<T: Pagable>: NSCopying {
    typealias PagableManagerFetchCompletion = (Error?) -> Void
    
    private(set) var currentPage = 0
    private(set) var objects: [T] = []
    private(set) var totalRecords: Int? //nil when there is 0 result
    let options: [String: String]?
    private(set) var moreToLoad = true
    
    private var isFetching = false
    private var numberOfTries = 0
    
    weak var delegate: PagableManagerDelegate?
    init(options: [String: String]? = nil) {
        self.options = options
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copyPagableManager = PagableManager<T>.init(options: self.options)
        copyPagableManager.currentPage = self.currentPage
        copyPagableManager.objects = self.objects
        copyPagableManager.totalRecords = self.totalRecords
        copyPagableManager.moreToLoad = self.moreToLoad
        return copyPagableManager
    }
    
    func removeObject(at index: Int) {
        objects.remove(at: index)
    }
    
    func insertObject(_ object: T, at index: Int) {
        objects.insert(object, at: index)
    }
    
    func reset() {
        self.totalRecords = nil
        self.currentPage = 0
        self.numberOfTries = 0
        self.isFetching = false
        self.objects = []
        self.moreToLoad = true
    }

    func fetch(_ completion: PagableManagerFetchCompletion? = nil) {
        if self.isFetching || !self.moreToLoad {
            return
        }

        if self.numberOfTries == Settings.numberOfRetries {
            //Retried several times but still failed
            self.numberOfTries = 0
            self.delegate?.pagableManagerDidFailFetching(self)
        }
        
        self.numberOfTries += 1
        self.isFetching = true
        
        //Workaround because News Archives page start from 1
        var currentPage: Int = 0
        if T.self == News.self {
            currentPage = self.currentPage + 1
        } else {
            currentPage = self.currentPage
        }
        
        let requestURLString = T.requestURLString(forPage: currentPage, withOptions: self.options)
        let requestURL = URL(string: requestURLString)!
        
        self.delegate?.pagableManagerDidBeginFetching(self)
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { [weak self] (response) in
            guard let `self` = self else { return }
            self.isFetching = false
            
            switch response.result {
            case .success:
                if let data = response.data,
                    let (newsList, totalRecords) = T.parseListFrom(data: data) {
        
                    if let `newsList` = newsList {
                        self.objects.append(contentsOf: newsList)
                        self.currentPage += 1
                    } else {
                        self.moreToLoad = false
                    }
                    
                    self.totalRecords = totalRecords
                    if let `totalRecords` = totalRecords {
                        //Make senses cause server sometimes returns more objects than totalRecords. (server's bug)
                        if self.objects.count >= totalRecords {
                            self.moreToLoad = false
                            //Temporary workaround for this server's bug
                            self.totalRecords = self.objects.count
                        }
                    }
                    
                    self.numberOfTries = 0
                    self.delegate?.pagableManagerDidFinishFetching(self)
                    completion?(nil)
                } else {
                    if let statusCode = response.response?.statusCode {
                        if statusCode == -999 || statusCode == 403 {
                            //Blocked by the server, automatically retry in 5 seconds later
                            self.delegate?.pagableManagerIsBeingBlocked(self)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: {
                                self.fetch()
                            })
                        } else {
                            //Unknown error
                            let error = NSError(domain: "", code: 2804, userInfo: nil)
                            completion?(error)
                            self.delegate?.pagableManagerDidFailFetching(self)
                        }
                    }
                }
            case .failure(let error):
                completion?(error)
                //Blocked by the server, automatically retry in 5 seconds later
                self.delegate?.pagableManagerIsBeingBlocked(self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: {
                    self.fetch()
                })
            }
        }
    }
}
