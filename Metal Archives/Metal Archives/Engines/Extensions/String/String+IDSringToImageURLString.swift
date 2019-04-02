//
//  String+ToResourceURLString.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 02/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension String {
    func idStringToImageURLString(imageExtension: ImageExtension = .jpg, imageType: ImageType = .release) -> String? {
        guard let equivalentInt = Int(self) else {
            return nil
        }
        
        var imagePath = ""
        
        if equivalentInt >= 1000 {
            imagePath = "\(self[0])/\(self[1])/\(self[2])/\(self[3])/"
            
        } else if equivalentInt >= 100 && equivalentInt <= 999 {
            imagePath = "\(self[0])/\(self[1])/\(self[2])/"
        } else if equivalentInt >= 10 && equivalentInt <= 99 {
            imagePath = "\(self[0])/\(self[1])/"
        } else if equivalentInt >= 1 && equivalentInt <= 9 {
            imagePath = "\(equivalentInt)/"
        }
        
        imagePath = imagePath + self + imageType.additionString + "." + imageExtension.rawValue
        
        return imagePath
    }
}
