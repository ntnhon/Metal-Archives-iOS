//
//  PhotoViewerViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 28/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import SDWebImage
import Toaster
import FirebaseAnalytics

private struct ScaleFactor {
    static let retinaToEye: CGFloat = 0.5
    static let faceBoundsToEye: CGFloat = 4.0
}

final class PhotoViewerViewController: BaseViewController {
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var funnyEyesButton: UIButton!
    @IBOutlet private weak var optionButton: UIButton!
    
    var photoURLString: String?
    var photoDescription: String?
    private var temporaryImageView: UIImageView = UIImageView(frame: .zero)
    private var originalRect: CGRect = .zero
    private let smokedBackgroundView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: .init(width: screenWidth, height: screenHeight)))
        view.backgroundColor = Settings.currentTheme.backgroundColor
        return view
    }()
    
    private var eyesOverlaid = false {
        didSet {
            let imageName = eyesOverlaid ? Ressources.Images.funny_eyes_selected : Ressources.Images.funny_eyes_unselected
            self.funnyEyesButton.setImage(UIImage(named: imageName), for: .normal)
        }
    }
    private var displayOnlyPhotoImageView = false {
        didSet {
            UIView.animate(withDuration: 0.35) { [weak self] in
                guard let `self` = self else { return }
                self.closeButton.isHidden = self.displayOnlyPhotoImageView
                self.descriptionLabel.isHidden = self.displayOnlyPhotoImageView
                self.funnyEyesButton.isHidden = self.displayOnlyPhotoImageView
                self.optionButton.isHidden = self.displayOnlyPhotoImageView
            }
        }
    }
    
    deinit {
        print("PhotoViewerViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addGestures()
        self.setPhoto()
    }
    
    override func initAppearance() {
        super.initAppearance()
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 10
        
        self.closeButton.tintColor = Settings.currentTheme.bodyTextColor
        self.funnyEyesButton.tintColor = Settings.currentTheme.bodyTextColor
        self.optionButton.tintColor = Settings.currentTheme.bodyTextColor
        self.descriptionLabel.textColor = Settings.currentTheme.bodyTextColor
        self.descriptionLabel.font = Settings.currentFontSize.secondaryTitleFont
        self.scrollView.backgroundColor = Settings.currentTheme.imageViewBackgroundColor
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //Resize image view to original size when changing device orientation
        self.scrollView.zoomScale = 1
    }
    override func viewWillDisappear(_ animated: Bool) {
        ToastCenter.default.cancelAll()
    }
    
    func present(in viewController: UIViewController, fromRect rect: CGRect) {
        originalRect = rect
        temporaryImageView.contentMode = .scaleAspectFit
        temporaryImageView.frame = rect
        if let photoURLString = photoURLString {
            temporaryImageView.sd_setImage(with: URL(string: photoURLString))
        }
        
        let containerController = viewController.navigationController ?? viewController
        containerController.addChild(self)
        containerController.view.addSubview(smokedBackgroundView)
        containerController.view.addSubview(temporaryImageView)
        containerController.view.addSubview(view)
        self.didMove(toParent: containerController)
        
        smokedBackgroundView.alpha = 0
        view.isHidden = true

        UIView.animate(withDuration: Settings.animationDuration, animations: { [unowned self] in
            self.smokedBackgroundView.alpha = 1
            self.temporaryImageView.frame = CGRect(origin: .zero, size: .init(width: screenWidth, height: screenHeight))
        }) { [unowned self] _ in
            self.view.isHidden = false
            self.temporaryImageView.isHidden = true
        }
    }
    
    private func dismiss() {
        temporaryImageView.frame = photoImageView.frame
        temporaryImageView.isHidden = false
        view.isHidden = true
        
        UIView.animate(withDuration: Settings.animationDuration, animations: { [unowned self] in
            self.temporaryImageView.frame = self.originalRect
            self.temporaryImageView.alpha = 0
            self.smokedBackgroundView.alpha = 0
        }) { [unowned self] _ in
            self.willMove(toParent: nil)
            self.smokedBackgroundView.removeFromSuperview()
            self.temporaryImageView.removeFromSuperview()
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    private func setPhoto() {
        if let photoURLString = photoURLString, let photoDescription = self.photoDescription {
            self.photoImageView.sd_setImage(with: URL(string: photoURLString), completed: nil)
            self.descriptionLabel.text = photoDescription
        }
    }
    
    @IBAction func didTapCloseButton() {
        self.dismiss()
    }
    
    @IBAction func didTapOptionButton() {
        var alert: UIAlertController!
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        }
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { (action) in
            if let image = self.photoImageView.image {
                let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                self.present(activityController, animated: true, completion: nil)
                
                if self.eyesOverlaid {
                    Analytics.logEvent(AnalyticsEvent.ShareFunnyEyesPhoto, parameters: nil)
                } else {
                    Analytics.logEvent(AnalyticsEvent.SharePhoto, parameters: nil)
                }
            }
        }
        
        let saveAction = UIAlertAction(title: "Save to Photos", style: .default) { (action) in
            if let _ = self.canAccessToPhotoLibrary(), let image = self.photoImageView.image {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        [shareAction, saveAction, cancelAction].forEach { alert.addAction($0) }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        //Save photo call back
        if let _ = error {
            Toast(text: "Error! Photo had not been saved.", duration: Delay.short).show()
        } else {
            Toast(text: "Photo successfully saved to your library!", duration: Delay.short).show()
            
            if self.eyesOverlaid {
                Analytics.logEvent(AnalyticsEvent.SaveFunnyEyesPhoto, parameters: nil)
            } else {
                Analytics.logEvent(AnalyticsEvent.SavePhoto, parameters: nil)
            }
        }
    }
    
    @IBAction func didTapFunnyEyesButton() {
        self.funnyEyesButton.isUserInteractionEnabled = false
        
        if self.eyesOverlaid {
            self.setPhoto()
            self.eyesOverlaid = false
            self.funnyEyesButton.isUserInteractionEnabled = true
            return
        }
        
        guard let image = self.photoImageView.image else { return }
        let (eyesDetected, overlayImage) = self.faceOverlayImageFrom(image)
        if eyesDetected {
            self.eyesOverlaid = true
            DispatchQueue.main.async { [weak self] in
                ToastCenter.default.cancelAll()
                Toast(text: "😳😳😳", duration: Delay.short).show()
                self?.fadeInNewImage(overlayImage!, completion: {
                    self?.funnyEyesButton.isUserInteractionEnabled = true
                })
            }
            
            Analytics.logEvent(AnalyticsEvent.MakeFunnyEyes, parameters: nil)
        } else {
            ToastCenter.default.cancelAll()
            Toast(text: "No 👀 detected", duration: Delay.short).show()
            self.eyesOverlaid = false
            self.funnyEyesButton.isUserInteractionEnabled = true
        }
        
    }
    
    private func addGestures() {
        self.photoImageView.isUserInteractionEnabled = true
        
        let tapPhotoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapPhoto))
        tapPhotoGestureRecognizer.numberOfTapsRequired = 1
        self.photoImageView.addGestureRecognizer(tapPhotoGestureRecognizer)
        
        let doubleTapPhotoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapPhoto(gesture:)))
        doubleTapPhotoGestureRecognizer.numberOfTapsRequired = 2
        self.photoImageView.addGestureRecognizer(doubleTapPhotoGestureRecognizer)
        
        let longPressPhotoGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didTapOptionButton))
        self.photoImageView.addGestureRecognizer(longPressPhotoGestureRecognizer)
        
        let panPhotoGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanPhoto(gesture:)))
        self.photoImageView.addGestureRecognizer(panPhotoGestureRecognizer)
        
        let panScrollViewGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanPhoto(gesture:)))
        self.scrollView.addGestureRecognizer(panScrollViewGestureRecognizer)
        
        // When user double taps => ignore single tap
        tapPhotoGestureRecognizer.require(toFail: doubleTapPhotoGestureRecognizer)
    }
    
    @objc private func didTapPhoto() {
        if self.scrollView.zoomScale > 1 {
            self.scrollView.setZoomScale(1, animated: true)
            self.displayOnlyPhotoImageView = false
        } else {
            self.displayOnlyPhotoImageView = !self.displayOnlyPhotoImageView
        }
    }
    
    @objc private func didDoubleTapPhoto(gesture: UITapGestureRecognizer) {
        if self.scrollView.zoomScale > 1 {
            self.scrollView.setZoomScale(1, animated: true)
            self.displayOnlyPhotoImageView = false
        } else {
            self.scrollView.setZoomScale(3.0, animated: true)
            self.displayOnlyPhotoImageView = true
        }
    }
    
    @objc private func didPanPhoto(gesture: UIPanGestureRecognizer) {
        guard scrollView.zoomScale == 1.0 else { return }
        
        let translation = gesture.translation(in: view)
        let alpha = abs(translation.y) / (screenHeight / 2)
        
        switch gesture.state {
        case .began, .changed:
            smokedBackgroundView.alpha = alpha
            view.isHidden = true
            temporaryImageView.isHidden = false
            temporaryImageView.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            
        case .ended, .cancelled:
            if abs(translation.y) < 100 {
                UIView.animate(withDuration: Settings.animationDuration, animations: { [unowned self] in
                    self.temporaryImageView.transform = .identity
                    self.smokedBackgroundView.alpha = 1
                }) { _ in
                    self.temporaryImageView.isHidden = true
                    self.view.isHidden = false
                }
            } else {
                dismiss()
            }
            
        default:
            return
        }

    }
}

//MARK: - ScrollViewDelegate
extension PhotoViewerViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoImageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.displayOnlyPhotoImageView = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if self.scrollView.zoomScale == 1 {
            self.displayOnlyPhotoImageView = false
        }
    }
}

//MARK: - Face overlay
private extension PhotoViewerViewController {
    func faceOverlayImageFrom(_ image: UIImage) -> (Bool, UIImage?) {
        let detector = CIDetector(ofType: CIDetectorTypeFace,
                                  context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        // Get features from the image
        let newImage = CIImage(cgImage: image.cgImage!)
        let features = detector!.features(in: newImage) as! [CIFaceFeature]
        
        UIGraphicsBeginImageContext(image.size)
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        // Draws this in the upper left coordinate system
        image.draw(in: imageRect, blendMode: .normal, alpha: 1.0)
        
        let context = UIGraphicsGetCurrentContext()
        
        //Return if there is no facefeatures detected
        if features.count == 0 {
            return (false, nil)
        }
        
        for faceFeature in features {
            let faceRect = faceFeature.bounds
            context!.saveGState()
            
            // CI and CG work in different coordinate systems, we should translate to
            // the correct one so we don't get mixed up when calculating the face position.
            context!.translateBy(x: 0.0, y: imageRect.size.height)
            context!.scaleBy(x: 1.0, y: -1.0)
            
            //Return if there is no eyes detected
            if !faceFeature.hasLeftEyePosition || !faceFeature.hasRightEyePosition {
                return (false, nil)
            }
            
            
            if faceFeature.hasLeftEyePosition {
                let leftEyePosition = faceFeature.leftEyePosition
                let eyeWidth = faceRect.size.width / ScaleFactor.faceBoundsToEye
                let eyeHeight = faceRect.size.height / ScaleFactor.faceBoundsToEye
                let eyeRect = CGRect(x: leftEyePosition.x - eyeWidth / 2.0,
                                     y: leftEyePosition.y - eyeHeight / 2.0,
                                     width: eyeWidth,
                                     height: eyeHeight)
                drawEyeBallForFrame(eyeRect)
            }
            
            if faceFeature.hasRightEyePosition {
                let leftEyePosition = faceFeature.rightEyePosition
                let eyeWidth = faceRect.size.width / ScaleFactor.faceBoundsToEye
                let eyeHeight = faceRect.size.height / ScaleFactor.faceBoundsToEye
                let eyeRect = CGRect(x: leftEyePosition.x - eyeWidth / 2.0,
                                     y: leftEyePosition.y - eyeHeight / 2.0,
                                     width: eyeWidth,
                                     height: eyeHeight)
                drawEyeBallForFrame(eyeRect)
            }
            
            context!.restoreGState();
        }
        
        let overlayImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return (true, overlayImage!)
    }
    
    func faceRotationInRadians(leftEyePoint startPoint: CGPoint, rightEyePoint endPoint: CGPoint) -> CGFloat {
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let angleInRadians = CGFloat(atan2f(Float(deltaY), Float(deltaX)))
        
        return angleInRadians;
    }
    
    func drawEyeBallForFrame(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.addEllipse(in: rect)
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillPath()
        
        let eyeSizeWidth = rect.size.width * ScaleFactor.retinaToEye
        let eyeSizeHeight = rect.size.height * ScaleFactor.retinaToEye
        
        var x = CGFloat(arc4random_uniform(UInt32(rect.size.width - eyeSizeWidth)))
        var y = CGFloat(arc4random_uniform(UInt32(rect.size.height - eyeSizeHeight)))
        x += rect.origin.x
        y += rect.origin.y
        
        let eyeSize = min(eyeSizeWidth, eyeSizeHeight)
        let eyeBallRect = CGRect(x: x, y: y, width: eyeSize, height: eyeSize)
        context?.addEllipse(in: eyeBallRect)
        context?.setFillColor(UIColor.black.cgColor)
        context?.fillPath()
    }
    
    func fadeInNewImage(_ newImage: UIImage, completion: @escaping () ->  Void) {
        let tmpImageView = UIImageView(image: newImage)
        tmpImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tmpImageView.contentMode = self.photoImageView.contentMode
        tmpImageView.frame = self.photoImageView.bounds
        tmpImageView.alpha = 0.0
        self.photoImageView.addSubview(tmpImageView)

        UIView.animate(withDuration: 0.75, animations: {
            tmpImageView.alpha = 1.0
        }, completion: { finished in
            self.photoImageView.image = newImage
            tmpImageView.removeFromSuperview()
            completion()
        })
    }
}
