//
//  Thumbnailable.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 03/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

class ThumbnailableObject: NSObject {
    let urlString: String
    let id: String
    let imageType: ImageType
    private(set) var noImage = false
    private(set) var imageURLString: String?
    
    // Photo name on server can be guessed by contructing a name base on object type
    // but photo extention can be any type, so we have to try with most well-known types manually
    private var triedPNG = false
    private var triedJPEG = false
    private var triedGIF = false
    
    override var description: String {
        return self.id
    }
    
    init?(urlString: String, imageType: ImageType) {
        if let id = urlString.components(separatedBy: "/").last {
            self.id = id
        } else {
            return nil
        }
        
        self.urlString = urlString
        self.imageType = imageType
        super.init()
        self.generateImageURLString()
    }
    
    //Work around to for image to be load at every cell display
    //case server keeps refusing to give image even the URL is right
    func resetStates() {
        self.generateImageURLString()
        self.triedPNG = false
        self.triedJPEG = false
        self.triedGIF = false
    }
    
    func foundRightURL() {
        self.noImage = false
    }
    
    private func generateImageURLString() {
        if let imageURLPath = id.idStringToImageURLString(imageExtension: .jpg, imageType: imageType) {
            self.imageURLString = MAImageBaseURLString + imageURLPath
            self.noImage = false
        } else {
            self.noImage = true
        }
    }
    
    func retryGenerateImageURLString() {
        if noImage {
            return
        }
        
        if !triedPNG {
            if let imageURLPath = id.idStringToImageURLString(imageExtension: .png, imageType: imageType) {
                self.imageURLString = MAImageBaseURLString + imageURLPath
                triedPNG = true
                return
            }
        }
        
        if !triedJPEG {
            if let imageURLPath = id.idStringToImageURLString(imageExtension: .jpeg, imageType: imageType) {
                self.imageURLString = MAImageBaseURLString + imageURLPath
                triedJPEG = true
                return
            }
        }
        
        if !triedGIF {
            if let imageURLPath = id.idStringToImageURLString(imageExtension: .gif, imageType: imageType) {
                self.imageURLString = MAImageBaseURLString + imageURLPath
                
                //Last resort => release has really no image
                triedGIF = true
                return
            }
        }
        
        noImage = true
    }
}
