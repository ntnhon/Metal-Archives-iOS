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
import MBProgressHUD

private struct ScaleFactor {
    static let retinaToEye: CGFloat = 0.5
    static let faceBoundsToEye: CGFloat = 4.0
}

final class PhotoViewerViewController: BaseViewController {
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var detectEyesButton: UIButton!
    @IBOutlet private weak var optionButton: UIButton!
    @IBOutlet private weak var buttonsTopSpaceConstraint: NSLayoutConstraint!
    
    var photoURLString: String?
    var photoDescription: String?
    
    private weak var sourceImageView: UIImageView?
    private var sourceRect: CGRect = .zero
    private var temporaryImageView: UIImageView = UIImageView(frame: .zero)
    private let dimBackgroundView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: .init(width: screenWidth, height: screenHeight)))
        view.backgroundColor = Settings.currentTheme.backgroundColor
        return view
    }()
    
    private var eyesOverlaid = false {
        didSet {
            let imageName = eyesOverlaid ? Ressources.Images.funny_eyes_selected : Ressources.Images.funny_eyes_unselected
            detectEyesButton.setImage(UIImage(named: imageName), for: .normal)
        }
    }
    
    private var displayOnlyPhotoImageView = false {
        didSet {
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.closeButton.isHidden = self.displayOnlyPhotoImageView
                self.descriptionLabel.isHidden = self.displayOnlyPhotoImageView
                self.detectEyesButton.isHidden = self.displayOnlyPhotoImageView
                self.optionButton.isHidden = self.displayOnlyPhotoImageView
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addGestures()
        setPhoto()
        Analytics.logEvent("open_photo_viewer", parameters: nil)
    }
    
    override func initAppearance() {
        super.initAppearance()
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 10
        closeButton.tintColor = Settings.currentTheme.bodyTextColor
        detectEyesButton.tintColor = Settings.currentTheme.bodyTextColor
        optionButton.tintColor = Settings.currentTheme.bodyTextColor
        descriptionLabel.textColor = Settings.currentTheme.bodyTextColor
        descriptionLabel.font = Settings.currentFontSize.secondaryTitleFont
        scrollView.backgroundColor = Settings.currentTheme.imageViewBackgroundColor
        buttonsTopSpaceConstraint.constant = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { [.portrait, .landscape] }
    
    override var shouldAutorotate: Bool { true }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //Resize image view to original size when changing device orientation
        scrollView.zoomScale = 1
    }

    override func viewWillDisappear(_ animated: Bool) {
        ToastCenter.default.cancelAll()
    }
    
    func present(in viewController: UIViewController, fromImageView imageView: UIImageView) {
        sourceImageView = imageView
        let rect = imageView.positionIn(view: viewController.view)
        sourceRect = rect
        
        sourceImageView?.isHidden = true
        
        // init temporaryImageView
        temporaryImageView.contentMode = .scaleAspectFit
        temporaryImageView.frame = rect
        if let photoURLString = photoURLString {
            temporaryImageView.sd_setImage(with: URL(string: photoURLString))
        }
        
        let containerController = viewController.navigationController ?? viewController
        containerController.addChild(self)
        containerController.view.addSubview(dimBackgroundView)
        containerController.view.addSubview(temporaryImageView)
        containerController.view.addSubview(view)
        self.didMove(toParent: containerController)

        dimBackgroundView.alpha = 0
        view.frame = CGRect(origin: .zero, size: UIScreen.main.bounds.size)
        view.isHidden = true

        UIView.animate(withDuration: Settings.animationDuration, animations: { [unowned self] in
            self.dimBackgroundView.alpha = 1
            self.temporaryImageView.frame = CGRect(origin: .zero, size: .init(width: screenWidth, height: screenHeight))
            self.hideStatusBar()
        }) { [unowned self] _ in
            self.view.isHidden = false
            self.temporaryImageView.isHidden = true
        }
    }
    
    private func dismiss(fromPhotoImageViewOriginalFrame: Bool = true) {
        if fromPhotoImageViewOriginalFrame {
            temporaryImageView.frame = photoImageView.frame
        }

        temporaryImageView.isHidden = false
        view.isHidden = true
        
        UIView.animate(withDuration: Settings.animationDuration, animations: { [unowned self] in
            self.temporaryImageView.frame = self.sourceRect
            self.dimBackgroundView.alpha = 0
            self.showStatusBar()
        }) { [unowned self] _ in
            self.sourceImageView?.isHidden = false
            self.willMove(toParent: nil)
            self.dimBackgroundView.removeFromSuperview()
            self.temporaryImageView.removeFromSuperview()
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    private func setPhoto() {
        if let photoURLString = photoURLString, let photoUrl = URL(string: photoURLString) {
            self.photoImageView.sd_setImage(with: photoUrl, completed: nil)
        }
        descriptionLabel.text = photoDescription
    }
    
    @IBAction private func closeAction() { dismiss() }
    
    @IBAction private func optionAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet)
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { [unowned self] _ in
            guard let image = photoImageView.image else { return }
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            present(activityController, animated: true, completion: nil)
            Analytics.logEvent(eyesOverlaid ? "share_funny_eyes_photo" : "share_photo", parameters: nil)
        }
        
        let saveAction = UIAlertAction(title: "Save to Photos", style: .default) { [unowned self] _ in
            if let _ = self.canAccessToPhotoLibrary(), let image = self.photoImageView.image {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        [shareAction, saveAction, cancelAction].forEach { alert.addAction($0) }
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        //Save photo call back
        if let _ = error {
            Toast.displayMessageShortly("Error saving photo 😵")
        } else {
            Toast.displayMessageShortly("Saved to your Photos")
            Analytics.logEvent(eyesOverlaid ? "save_funny_eyes_photo" : "save_photo", parameters: nil)
        }
    }
    
    @IBAction private func detectEyesAction() {
        // Un-overlay photo, set back to normal
        if eyesOverlaid {
            setPhoto()
            temporaryImageView.image = photoImageView.image
            eyesOverlaid = false
            return
        }
        
        guard let image = photoImageView.image else { return }

        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = "Finding some 👀"
        DispatchQueue.global(qos: .background).async { [unowned self] in
            let overlayImage = image.faceOverlay()
            
            DispatchQueue.main.async {
                hud.hide(animated: true)
                
                if let overlayImage = overlayImage {
                    self.eyesOverlaid = true
                    Toast.displayMessageShortly("😳😳😳")
                    self.fadeInNewImage(overlayImage)
                    self.temporaryImageView.image = overlayImage
                    Analytics.logEvent("make_funny_eyes", parameters: nil)
                } else {
                    Toast.displayMessageShortly("No 👀 detected")
                    self.eyesOverlaid = false
                }
            }
        }
    }
    
    private func fadeInNewImage(_ newImage: UIImage) {
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
        })
    }
    
    private func addGestures() {
        self.photoImageView.isUserInteractionEnabled = true
        
        let tapPhotoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapPhoto))
        tapPhotoGestureRecognizer.numberOfTapsRequired = 1
        photoImageView.addGestureRecognizer(tapPhotoGestureRecognizer)
        
        let doubleTapPhotoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapPhoto(gesture:)))
        doubleTapPhotoGestureRecognizer.numberOfTapsRequired = 2
        photoImageView.addGestureRecognizer(doubleTapPhotoGestureRecognizer)
        
        let longPressPhotoGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(optionAction))
        photoImageView.addGestureRecognizer(longPressPhotoGestureRecognizer)
        
        let panScrollViewGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanPhoto(gesture:)))
        panScrollViewGestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(panScrollViewGestureRecognizer)
        
        // When user double taps => ignore single tap
        tapPhotoGestureRecognizer.require(toFail: doubleTapPhotoGestureRecognizer)
    }
    
    @objc private func didTapPhoto() {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
            displayOnlyPhotoImageView = false
        } else {
            displayOnlyPhotoImageView = !displayOnlyPhotoImageView
        }
    }
    
    @objc private func didDoubleTapPhoto(gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
            displayOnlyPhotoImageView = false
        } else {
            scrollView.setZoomScale(3.0, animated: true)
            displayOnlyPhotoImageView = true
        }
    }
    
    @objc private func didPanPhoto(gesture: UIPanGestureRecognizer) {
        guard scrollView.zoomScale == 1.0 else { return }
        
        let translation = gesture.translation(in: view)
        let alpha = abs(translation.y) / (screenHeight / 2)
        let scaleRatio = abs(1 - (translation.y / screenHeight))
        
        switch gesture.state {
        case .began, .changed:
            dimBackgroundView.alpha = alpha
            view.isHidden = true
            temporaryImageView.isHidden = false
            
            var transform = CGAffineTransform.identity
            transform = transform.translatedBy(x: translation.x, y: translation.y)
            transform = transform.scaledBy(x: scaleRatio, y: scaleRatio)
            temporaryImageView.transform = transform
            
        case .ended, .cancelled:
            if abs(translation.y) < 100 {
                UIView.animate(withDuration: Settings.animationDuration, animations: { [unowned self] in
                    self.temporaryImageView.transform = .identity
                    self.dimBackgroundView.alpha = 1
                }) { _ in
                    self.temporaryImageView.isHidden = true
                    self.view.isHidden = false
                }
            } else {
                dismiss(fromPhotoImageViewOriginalFrame: false)
            }
            
        default:
            return
        }

    }
}

// MARK: - UIGestureRecognizerDelegate
extension PhotoViewerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - ScrollViewDelegate
extension PhotoViewerViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { photoImageView }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        displayOnlyPhotoImageView = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        displayOnlyPhotoImageView = scrollView.zoomScale != 1
    }
}

// MARK: - Eyes detection
private extension UIImage {
    func faceOverlay() -> UIImage? {
        let detector = CIDetector(ofType: CIDetectorTypeFace,
                                  context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        // Get features from the image
        let newImage = CIImage(cgImage: cgImage!)
        let features = detector!.features(in: newImage) as! [CIFaceFeature]
        
        UIGraphicsBeginImageContext(size)
        let imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // Draws this in the upper left coordinate system
        draw(in: imageRect, blendMode: .normal, alpha: 1.0)
        
        let context = UIGraphicsGetCurrentContext()
        
        //Return if there is no facefeatures detected
        if features.count == 0 {
            return nil
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
                return nil
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
        
        return overlayImage
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
}
