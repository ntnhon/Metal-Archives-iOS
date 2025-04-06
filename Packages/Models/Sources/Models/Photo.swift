//
//  Photo.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/10/2021.
//

import UIKit

public struct Photo: Sendable {
    public let image: UIImage
    public let description: String

    public init(image: UIImage, description: String) {
        self.image = image
        self.description = description
    }
}
