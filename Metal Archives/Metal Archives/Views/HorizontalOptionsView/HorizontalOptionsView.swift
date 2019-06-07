//
//  HorizontalOptionsView.swift
//  HorizontalOptionsView
//
//  Created by Thanh-Nhon Nguyen on 06/06/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

fileprivate let stackViewSpacing: CGFloat = 10

protocol HorizontalOptionsViewDelegate: class {
    func horizontalOptionsView(_ horizontalOptionsView: HorizontalOptionsView, didSelectItemAt index: Int)
}

final class HorizontalOptionsView: UIView {
    private let options: [String]
    private let font: UIFont
    private let textColor: UIColor
    private let normalColor: UIColor
    private let highlightColor: UIColor
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private var isAnimating = false
    private var stackView: UIStackView!
    private var lastSelectedLabel: UILabel!
    
    weak var delegate: HorizontalOptionsViewDelegate?
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
    
    init(options: [String], font: UIFont, textColor: UIColor, normalColor: UIColor, highlightColor: UIColor) {
        self.options = options
        self.font = font
        self.textColor = textColor
        self.normalColor = normalColor
        self.highlightColor = highlightColor
        super.init(frame: .zero)
        initilize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func initilize() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.contentInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        
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
            label.clipsToBounds = true
            label.text = option
            label.font = font
            label.textColor = textColor
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.layer.borderColor = textColor.cgColor
            label.layer.borderWidth = 1
            label.layer.cornerRadius = 6
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
            } else {
                defocus(label)
            }
        }
    }
    
    @objc private func tappedLabel(sender: UITapGestureRecognizer) {
        let selectedLabel = sender.view as! UILabel
        animateChange(selectedLabel: selectedLabel)
    }
    
    private func animateChange(selectedLabel: UILabel) {
        guard !isAnimating && selectedLabel != lastSelectedLabel else { return }
        self.isAnimating.toggle()
        UIView.animate(withDuration: 0.35, animations: {
            [unowned self] in
            self.focus(selectedLabel)
            self.defocus(self.lastSelectedLabel)
        }) { [unowned self] (finished) in
            self.isAnimating.toggle()
            self.lastSelectedLabel = selectedLabel
            self.delegate?.horizontalOptionsView(self, didSelectItemAt: selectedLabel.tag)
        }
    }
    
    private func focus(_ label: UILabel) {
        label.layer.backgroundColor = highlightColor.cgColor
        label.layer.borderColor = highlightColor.cgColor
    }
    
    private func defocus(_ label: UILabel) {
        label.layer.backgroundColor = normalColor.cgColor
        label.layer.borderColor = textColor.cgColor
    }
}
