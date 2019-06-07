//
//  HorizontalMenuView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

fileprivate let shuttleViewHeight: CGFloat = 3
fileprivate let shuttleViewSpacing: CGFloat = 4
fileprivate let stackViewSpacing: CGFloat = 20

protocol HorizontalMenuViewDelegate: class {
    func horizontalMenu(_ horizontalMenu: HorizontalMenuView, didSelectItemAt index: Int)
}

final class HorizontalMenuView: UIView {
    private let options: [String]
    private let font: UIFont
    private let normalColor: UIColor
    private let highlightColor: UIColor

    private let shuttleView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: shuttleViewHeight)))
        return view
    }()
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private var stackView: UIStackView!
    private var lastSelectedLabel: UILabel!
    
    var selectedIndex: Int {
        get {
            return lastSelectedLabel.tag
        }
        set {
            if let selectedLabel = (stackView.viewWithTag(newValue) as? UILabel) {
                animateChange(selectedLabel: selectedLabel)
            }
        }
    }
    
    weak var delegate: HorizontalMenuViewDelegate?
    
    lazy var intrinsicHeight: CGFloat = {
        return self.lastSelectedLabel.intrinsicContentSize.height + self.shuttleView.frame.height + shuttleViewSpacing
    }()
    
    init(options: [String], font: UIFont, normalColor: UIColor, highlightColor: UIColor) {
        self.options = options
        self.font = font
        self.normalColor = normalColor
        self.highlightColor = highlightColor
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        // Init scrollView
        addSubview(scrollView)
        scrollView.contentInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        
        // Init shuttleView
        scrollView.addSubview(shuttleView)
        shuttleView.backgroundColor = highlightColor
        
        // Init stackView
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = stackViewSpacing
        stackView.distribution = .fill
        scrollView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
            ])
        
        var i = 0
        for option in options {
            let label = SpaciousLabel()
            label.text = option
            label.font = font
            label.textColor = normalColor
            label.textAlignment = .center
            label.textInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
            label.tag = i
            i += 1
            stackView.addArrangedSubview(label)
            
            label.isUserInteractionEnabled = true
            let labelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedLabel(sender:)))
            label.addGestureRecognizer(labelTapGestureRecognizer)
            
            if lastSelectedLabel == nil {
                lastSelectedLabel = label
                focus(lastSelectedLabel)
                alignShuttle(with: lastSelectedLabel)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        alignShuttle(with: lastSelectedLabel)
    }
    
    @objc private func tappedLabel(sender: UITapGestureRecognizer) {
        let label = sender.view as! UILabel
        animateChange(selectedLabel: label)
    }
    
    private func animateChange(selectedLabel: UILabel) {
        guard selectedLabel != lastSelectedLabel else { return }
        
        self.focus(selectedLabel)
        self.defocus(self.lastSelectedLabel)
        self.scrollToNearestLabel(of: selectedLabel)
        self.lastSelectedLabel = selectedLabel
        self.delegate?.horizontalMenu(self, didSelectItemAt: selectedLabel.tag)
        
        UIView.animate(withDuration: 0.35) { [unowned self] in
            self.alignShuttle(with: selectedLabel)
        }
    }

    private func alignShuttle(with label: UILabel) {
        let newX = label.frame.origin.x - stackViewSpacing / 2
        let newOrigin = CGPoint(x: newX, y: label.frame.height + shuttleViewSpacing)
        let newSize = CGSize(width: label.frame.width + stackViewSpacing, height: shuttleView.frame.height)
        let newFrame = CGRect(origin: newOrigin, size: newSize)
        shuttleView.frame = newFrame
    }
    
    private func focus(_ label: UILabel) {
        label.textColor = highlightColor
    }
    
    private func defocus(_ label: UILabel) {
        label.textColor = normalColor
    }
    
    private func scrollToNearestLabel(of label: UILabel) {
        let indexOfLabel = options.firstIndex(of: label.text!)!
        let indexOfLastSelectedLabel = options.firstIndex(of: lastSelectedLabel.text!)!
        
        var nearestLabel: UILabel?
        if indexOfLabel > indexOfLastSelectedLabel {
            // shuttle goes to the right
            if indexOfLabel + 1 < options.count {
                nearestLabel = stackView.arrangedSubviews[indexOfLabel + 1] as? UILabel
            }
        } else {
            // shuttle goes to the left
            if indexOfLabel - 1 >= 0 {
                nearestLabel = stackView.arrangedSubviews[indexOfLabel - 1] as? UILabel
            }
        }
        
        if let nearestLabel = nearestLabel {
            scrollView.scrollRectToVisible(nearestLabel.frame, animated: true)
        }
    }
}
