/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
///
/// Derived from work by Trevor Harmon

import UIKit

extension UIImage {
    
    var hasAlpha: Bool {
        guard let cgImage = self.cgImage else { return false }
        let alpha = cgImage.alphaInfo
        return alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast
    }
    
    func imageWithAlpha() -> UIImage {
        if hasAlpha { return self }
        
        let scale = max(self.scale, 1)
        guard let imageRef = self.cgImage, let colorSpace = imageRef.colorSpace else { return self }
        let width = imageRef.width * Int(scale)
        let height = imageRef.height * Int(scale)
        
        guard let offscreenContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: UInt32(CGBitmapInfo.alphaInfoMask.rawValue) & UInt32(CGImageAlphaInfo.premultipliedLast.rawValue)) else {
            return self
        }
        
        offscreenContext.draw(imageRef, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let imageRefWithAlpha = offscreenContext.makeImage() else { return self }
        return UIImage(cgImage: imageRefWithAlpha, scale: self.scale, orientation: .up)
    }
    
    func transparentBorderImage(borderSize: CGFloat) -> UIImage {
        let image = imageWithAlpha()
        let scale = max(self.scale, 1)
        let scaledBorderSize = borderSize * scale
        let newRect = CGRect(x: 0, y: 0, width: image.size.width * scale + scaledBorderSize * 2, height: image.size.height * scale + scaledBorderSize * 2)
        guard let imageRef = self.cgImage, let colorSpace = imageRef.colorSpace else {
            return self
        }
        guard let bitmap = CGContext(data: nil, width: Int(newRect.size.width), height: Int(newRect.size.height), bitsPerComponent: imageRef.bitsPerComponent, bytesPerRow: imageRef.bytesPerRow, space: colorSpace, bitmapInfo: imageRef.bitmapInfo.rawValue) else {
            return self
        }
        
        let imageLocation = CGRect(x: scaledBorderSize, y: scaledBorderSize, width: image.size.width * scale, height: image.size.height * scale)
        bitmap.draw(imageRef, in: imageLocation)
        guard let borderImageRef = bitmap.makeImage() else {
            return self
        }
        
        let maskImageRef = newBorderMask(borderSize: scaledBorderSize, size: newRect.size)
        guard let transparentBorderImageRef = borderImageRef.masking(maskImageRef) else {
            return self
        }
        return UIImage(cgImage: transparentBorderImageRef, scale: self.scale, orientation: .up)
    }
    
    func newBorderMask(borderSize: CGFloat, size: CGSize) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        let maskContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 8, space: colorSpace, bitmapInfo: UInt32(CGImageAlphaInfo.none.rawValue))!
        
        maskContext.setFillColor(UIColor.black.cgColor)
        maskContext.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        maskContext.setFillColor(UIColor.white.cgColor)
        maskContext.fill(CGRect(x: borderSize, y: borderSize, width: size.width - borderSize * 2, height: size.height - borderSize * 2))
        
        return maskContext.makeImage()!
    }
    
}
