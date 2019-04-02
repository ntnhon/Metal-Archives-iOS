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
    
    func roundedCornerImage(cornerSize: CGFloat, borderSize: CGFloat) -> UIImage {
        let image = imageWithAlpha()
        let scale = max(self.scale, 1.0)
        let scaledBorderSize = CGFloat(borderSize) * scale
        
        guard let imageRef = cgImage, let colorSpace = imageRef.colorSpace else {
            return self
        }
        
        guard let context = CGContext(data: nil, width: Int(image.size.width * scale), height: Int(image.size.height * scale), bitsPerComponent: imageRef.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: imageRef.bitmapInfo.rawValue) else {
            return self
        }
        
        context.beginPath()
        addRoundedRectToPath(rect: CGRect(x: scaledBorderSize, y: scaledBorderSize, width: image.size.width * scale, height: image.size.height * scale), context: context, ovalWidth: cornerSize * scale, ovalHeight: cornerSize * scale)
        context.closePath()
        context.clip()
        
        context.draw(imageRef, in: CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale))
        guard let clippedImage = context.makeImage() else {
            return self
        }
        
        return UIImage(cgImage: clippedImage, scale: self.scale, orientation: .up)
    }
    
    func addRoundedRectToPath(rect: CGRect, context: CGContext, ovalWidth: CGFloat, ovalHeight: CGFloat) {
        if ovalWidth == 0 || ovalHeight == 0 {
            context.addRect(rect)
            return
        }
        context.saveGState()
        context.translateBy(x: rect.minX, y: rect.minY)
        context.scaleBy(x: ovalWidth, y: ovalHeight)
        let fw = rect.width / ovalWidth
        let fh = rect.height / ovalHeight
        context.move(to: CGPoint(x: fw, y: fh / 2))
        context.addArc(tangent1End: CGPoint(x: fw, y: fh), tangent2End: CGPoint(x: fw / 2, y: fh), radius: 1)
        context.addArc(tangent1End: CGPoint(x: 0, y: fh), tangent2End: CGPoint(x: 0, y: fh / 2), radius: 1)
        context.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: fw / 2, y: 0), radius: 1)
        context.addArc(tangent1End: CGPoint(x: fw, y: 0), tangent2End: CGPoint(x: fw, y: fh / 2), radius: 1)
        context.closePath()
        context.restoreGState()
    }
    
}
