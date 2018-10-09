//
//  AnimationView.swift
//  HOTextEffect
//
//  Created by Holaween on 2018/10/6.
//  Copyright © 2018年 OldDaddy0. All rights reserved.
//

import UIKit

class AnimationView: UIView {
    // protocol
    var text: NSString = "" {
        willSet {
            textCount = newValue.textCount()
        }
    }
    var font: UIFont = UIFont.systemFont(ofSize: 14)
    var color: UIColor = UIColor.white
    var duration: Double = 5
    var delay: Double = 0
    
    var frameInterval: NSInteger = 1
    var oneLineTextCount: Int = 15
    
    // abstract
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var currentTime: CFTimeInterval = 0
    var currentProgress: CGFloat = CGFloat.leastNonzeroMagnitude
    
    var oneLineTextSize: CGSize = CGSize(width: 0, height: 0)
    var oneTextSize: CGSize = CGSize(width: 0, height: 0)
    
    var textSize: CGSize = CGSize(width: 0, height: 0)
    var textCount: Int = 0
    var lineCount: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func showIn(_ view: UIView) {
        setupDefaultLayoutIn(view)
        setupAnimationData()
        
        // make sure last animation timer stopped
        stop()
        
        // start a new animation timer
        startTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(target: self, selector: #selector(refreshDisplay))
        displayLink?.frameInterval = frameInterval
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func remove() {
        stop()
        removeFromSuperview()
    }
    
    func snapshotWith(_ size: CGSize) -> UIImage? {
        return nil
    }
    
    func updateWith(_ time: CFTimeInterval, in progress: CGFloat) {
        if time >= duration {
            stop()
        }
    }
    
    func setupDefaultLayoutIn(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        let left = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([left, right, top, bottom])
    }
    
    func setupAnimationData() {
        oneLineTextSize = text.singleLineSize(font)
        oneTextSize = NSString.cnTextSize(font)
        
        var width = oneTextSize.width * CGFloat(oneLineTextCount)
        textSize = text.displaySizeWith(font: font, width: width, height: CGFloat.greatestFiniteMagnitude)
        if textSize.width < oneTextSize.width {
            oneTextSize = textSize
            width = oneTextSize.width * CGFloat(oneLineTextCount)
        }
        
        lineCount = max(1, Int(ceilf(Float(CGFloat(textCount)/CGFloat(oneLineTextCount)))))
    }
}

extension AnimationView {
    @objc private func refreshDisplay() {
        guard let displayLink = self.displayLink else {
            return
        }
        
        currentTime = displayLink.timestamp
        let t: CFTimeInterval = currentTime - startTime
        currentProgress = CGFloat(t/duration)
        
        updateWith(t, in: currentProgress)
    }
}
