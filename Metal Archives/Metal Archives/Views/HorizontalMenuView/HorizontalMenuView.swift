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

protocol HorizontalMenuViewDelegate {
    func didSelectItem(atIndex index: Int)
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
    
    var delegate: HorizontalMenuViewDelegate?
    
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
        
        let firstLabel = UILabel()
        firstLabel.text = options[0]
        firstLabel.font = font
        
        shuttleView.frame = CGRect(x: 0, y: firstLabel.intrinsicContentSize.height + shuttleViewSpacing, width: firstLabel.intrinsicContentSize.width, height: shuttleViewHeight)
        
        // Init stackView
        let spacing: CGFloat = 10
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = spacing
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
            let label = UILabel()
            label.text = option
            label.font = font
            label.textColor = normalColor
            label.textAlignment = .center
            label.tag = i
            i += 1
            stackView.addArrangedSubview(label)
            
            label.isUserInteractionEnabled = true
            let labelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedLabel(sender:)))
            label.addGestureRecognizer(labelTapGestureRecognizer)
            
            if lastSelectedLabel == nil {
                lastSelectedLabel = label
                lastSelectedLabel.textColor = highlightColor
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    @objc private func tappedLabel(sender: UITapGestureRecognizer) {
        let label = sender.view as! UILabel
        UIView.animate(withDuration: 0.35) { [unowned self] in
            self.focus(on: label)
            self.alignShuttle(with: label)
            self.lastSelectedLabel.textColor = self.normalColor
            label.textColor = self.highlightColor
            self.lastSelectedLabel = label
        }
        
        delegate?.didSelectItem(atIndex: label.tag)
    }
    
    private func alignShuttle(with label: UILabel) {
        let newX = label.frame.origin.x
        let newOrigin = CGPoint(x: newX, y: label.frame.height + shuttleViewSpacing)
        let newSize = CGSize(width: label.frame.width, height: shuttleView.frame.height)
        let newFrame = CGRect(origin: newOrigin, size: newSize)
        shuttleView.frame = newFrame
    }
    
    private func focus(on label: UILabel) {
        let indexOfLabel = options.firstIndex(of: label.text!)!
        let indexOfLastLabel = options.firstIndex(of: lastSelectedLabel.text!)!
        
        var focusedLabel: UILabel = label
        
        if indexOfLabel > indexOfLastLabel {
            // shuttle goes to the right
            if indexOfLabel + 1 < options.count {
                focusedLabel = stackView.arrangedSubviews[indexOfLabel + 1] as! UILabel
            }
        } else {
            // shuttle goes to the left
            if indexOfLabel - 1 >= 0 {
                focusedLabel = stackView.arrangedSubviews[indexOfLabel - 1] as! UILabel
            }
        }
        
        scrollView.scrollRectToVisible(focusedLabel.frame, animated: true)
    }
}
