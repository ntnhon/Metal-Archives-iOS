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
    
    func croppedImage(bounds: CGRect) -> UIImage {
        let scale = max(self.scale, 1)
        let scaledBounds = CGRect(x: bounds.origin.x * scale, y: bounds.origin.y * scale, width: bounds.size.width * scale, height: bounds.size.height * scale)
        guard let imageRef = cgImage?.cropping(to: scaledBounds) else {
            return self
        }
        let croppedImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: .up)
        return croppedImage
    }
    
    func thumbnailImage(_ size: Int, transparentBorder borderSize: CGFloat, cornerRadius: CGFloat, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        let resizedImage = self.resizedImage(withContentMode: .scaleAspectFill, bounds: CGSize(width: size, height: size), interpolationQuality: quality)
        let cropRect = CGRect(x: round((resizedImage.size.width - CGFloat(size)) / 2), y: round((resizedImage.size.height - CGFloat(size)) / 2), width: CGFloat(size), height: CGFloat(size))
        let croppedImage = resizedImage.croppedImage(bounds: cropRect)
        let transparentBorderImage = borderSize != 0 ? croppedImage.transparentBorderImage(borderSize: borderSize) : croppedImage
        return transparentBorderImage.roundedCornerImage(cornerSize: cornerRadius, borderSize: borderSize)
    }
    
    func resizedImage(newSize: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        let drawTransposed: Bool
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }
        let transform = transformForOrientation(newSize: newSize)
        return resizedImage(newSize: newSize, transform: transform, drawTransposed: drawTransposed, interpolationQuality: quality)
    }
    
    func resizedImage(withContentMode contentMode: UIView.ContentMode, bounds: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio: CGFloat
        switch contentMode {
        case .scaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
        case .scaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
        default:
            fatalError("Unsupported content mode: \(contentMode)")
        }
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        return resizedImage(newSize: newSize, interpolationQuality: quality)
    }
    
    func resizedImage(newSize: CGSize, transform: CGAffineTransform, drawTransposed: Bool, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        let scale = max(self.scale, 1)
        let newRect = CGRect(x: 0, y: 0, width: newSize.width * scale, height: newSize.height * scale).integral
        let transposedRect = CGRect(x: 0, y: 0, width: newRect.size.height, height: newRect.size.width)
        guard let imageRef = self.cgImage else {
            return self
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let bitmap = CGContext(data: nil, width: Int(newRect.size.width), height: Int(newRect.size.height), bitsPerComponent: 8, bytesPerRow: Int(newRect.size.width) * 4, space: colorSpace, bitmapInfo: UInt32(CGBitmapInfo.alphaInfoMask.rawValue) & UInt32(CGImageAlphaInfo.premultipliedLast.rawValue)) else {
            return self
        }
        bitmap.concatenate(transform)
        bitmap.interpolationQuality = quality
        bitmap.draw(imageRef, in: drawTransposed ? transposedRect : newRect)
        
        guard let newImageRef = bitmap.makeImage() else {
            return self
        }
        return UIImage(cgImage: newImageRef, scale: self.scale, orientation: .up)
    }
    
    func transformForOrientation(newSize: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: newSize.width, y: newSize.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: newSize.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: newSize.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        return transform
    }
    
}
