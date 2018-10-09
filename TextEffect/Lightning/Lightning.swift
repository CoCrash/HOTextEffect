//
//  Lightning.swift
//  HOTextEffect
//
//  Created by Holaween on 2018/10/6.
//  Copyright © 2018年 OldDaddy0. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum LightningStatus: Int {
    case lightning0 = 0 // ⚡️
    case lightning1, lightning2, lightning3, lightning4, lightning5, lightning6
    case laminate // 劈开
    case sunny
    
    func progress() -> CGFloat {
        switch self {
        case .lightning0:
            return 0.05
        case .lightning6:
            return 0.1665
        case .laminate:
            return 0.2165
        default:
            return 0.0
        }
    }
}

class LightningText: AnimationView {
    private var angle: Double = Double.leastNormalMagnitude
    private var lightningRef: LightningStatus = .sunny
    
    private lazy var lightningImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "img_lightning"))
        imageView.sizeToFit()
        imageView.isHidden = true
        self.addSubview(imageView)
        return imageView
    }()
    
    private lazy var fragmentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "img_fragment_white_4")
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        return imageView
    }()
    
    override func stop() {
        fragmentImageView.stopAnimating()
        super.stop()
    }
    
    override func setupAnimationData() {
        super.setupAnimationData()
        duration = 5
        frameInterval = 3
        lightningRef = .lightning0
        
        if textCount > 8 {
            angle = 13.0
        } else {
            angle = 30.0
        }
        
        var fragmentImages = [UIImage]()
        for i in 0..<53 {
            let name = "img_fragment_white_\(i+1)"
            if let image = UIImage(named: name) {
                fragmentImages.append(image)
            }
        }
        guard let image = fragmentImages.first else {
            setNeedsDisplay()
            return
        }
        fragmentImageView.frame = CGRect(x: -image.size.width, y: -image.size.height, width: image.size.width, height: image.size.height)
        fragmentImageView.animationRepeatCount = 1
        fragmentImageView.animationImages = fragmentImages
        
        setNeedsDisplay()
    }
    
    override func updateWith(_ time: CFTimeInterval, in progress: CGFloat) {
        super.updateWith(time, in: progress)
        
        // 5 percent progress no change
        if progress < LightningStatus.lightning0.progress() {
            backgroundColor = .clear
            return
        }
        
        lightningImageView.isHidden = false
        // below 16.65 percent
        if progress < LightningStatus.lightning6.progress() {
            switch lightningRef {
            case .lightning0:
                color = .white
                backgroundColor = .black
                break
            case .lightning1:
                color = .black
                backgroundColor = .white
                break
            case .lightning2:
                color = .clear
                backgroundColor = .gray
                break
            case .lightning3:
                color = .white
                backgroundColor = .black
                break
            case .lightning4:
                color = .black
                backgroundColor = .white
                break
            case .lightning5:
                color = .clear
                backgroundColor = .gray
                break
            default:
                color = .white
                backgroundColor = .clear
                break
            }
            
            let rawValue = lightningRef.rawValue + 1
            if LightningStatus.lightning6.rawValue <= rawValue {
                lightningRef = .lightning0
            } else {
                lightningRef = LightningStatus(rawValue: rawValue)!
            }
            return
        }
        
        // 劈死你
        lightningRef = .laminate
        if progress > LightningStatus.laminate.progress()
            && false == lightningImageView.isHidden {
            lightningImageView.isHidden = true
        }
        color = .white
        backgroundColor = .clear
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            super.draw(rect)
            return
        }
        // start
        UIGraphicsPushContext(context)
        context.setTextDrawingMode(.fill)
        
        let style: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = .center
        
        let attribute = [NSAttributedString.Key.font:font, NSAttributedString.Key.foregroundColor:color, NSAttributedString.Key.paragraphStyle:style]
        
        context.saveGState()
        
        // calculate positions
        var xTemp = self.center.x - textSize.width/2.0
        var yTemp = self.center.y - textSize.height/2.0
        let topLeft = CGPoint(x: xTemp, y: yTemp)
    
        xTemp = self.center.x + textSize.width/2.0
        yTemp = self.center.y + textSize.height/2.0
        let bottomRight = CGPoint(x: xTemp, y: yTemp)
        
        var xOffset:CGFloat = 0
        if textCount > 8 {
            // 比例位置
            xOffset = topLeft.x + textSize.width * 0.66666
        } else if textCount > 1 {
            // 倒数第二个字的中心坐标
            if textSize.width <= oneTextSize.width {
                xOffset = topLeft.x + textSize.width * 0.8
            } else {
                xOffset = topLeft.x + textSize.width - oneTextSize.width * 1.3
            }
        } else {
            if textSize.width <= oneTextSize.width {
                xOffset = topLeft.x + textSize.width * 0.8
            } else {
                xOffset = topLeft.x + textSize.width
            }
        }
        var frame = lightningImageView.frame
        frame.origin.x = xOffset - oneTextSize.width
        frame.origin.y = -(frame.size.height - topLeft.y - font.lineHeight)
        lightningImageView.frame = frame
        let center = CGPoint(x: xOffset, y: topLeft.y)

        var rotatePoint = center
        rotatePoint.y += textSize.height
        rotatePoint = rotateWith(rotatePoint, center: center, angle: -angle)
        rotatePoint.y = bottomRight.y
        
        // draw normal text
        let path: CGMutablePath = CGMutablePath()
        path.move(to: topLeft)
        path.addLine(to: center)
        path.addLine(to: rotatePoint)
        path.addLine(to: CGPoint(x: topLeft.x, y: bottomRight.y))
        
        path.closeSubpath()
        context.addPath(path)
        context.clip()
        
        if Double.leastNormalMagnitude == angle {
            context.setShadow(offset: CGSize(width: 1, height: 1), blur: 5, color: color.cgColor)
        }
        
        let attributeText: NSAttributedString = NSAttributedString(string: text as String, attributes: attribute)
        attributeText.draw(in: CGRect(x: topLeft.x, y: topLeft.y, width: textSize.width, height: textSize.height))
        context.restoreGState()
        context.saveGState()
        
        // draw rotate effect
        var progress: CGFloat = 0.0 // 0..1
        if currentProgress > LightningStatus.lightning6.progress() {
            progress = min(1.0, CGFloat(currentProgress - LightningStatus.lightning6.progress())/LightningStatus.lightning0.progress())
        }
        
        var degress: CGFloat = CGFloat(angle) * progress
        degress = degress * .pi/180
        
        var transform: CGAffineTransform = .identity
        transform = transform.translatedBy(x: rotatePoint.x, y: rotatePoint.y)
        transform = transform.rotated(by: degress)
        
        let path1: CGMutablePath = CGMutablePath()
        path1.move(to: CGPoint(x: center.x-rotatePoint.x, y: -textSize.height), transform: transform)
        path1.addLine(to: CGPoint(x: bottomRight.x-rotatePoint.x, y: -textSize.height), transform: transform)
        path1.addLine(to: CGPoint(x: bottomRight.x-rotatePoint.x, y: 0), transform: transform)
        path1.addLine(to: .zero, transform: transform)
        path1.closeSubpath()
        context.addPath(path1)
        context.clip()
        
        if Double.leastNormalMagnitude == angle {
            context.setShadow(offset: CGSize(width: 1, height: 1), blur: 5, color: color.cgColor)
        }
        
        context.translateBy(x: rotatePoint.x, y: rotatePoint.y)
        context.rotate(by: degress)
        
        let drawRect = CGRect(x: -(rotatePoint.x - topLeft.x), y: -textSize.height, width: textSize.width, height: textSize.height)
        attributeText.draw(in: drawRect)
        
        context.restoreGState()
        context.saveGState()
        
        // fragmentimageview
        var adjustRotatePoint = rotatePoint
        if textCount > oneLineTextCount {
            let endWidth = oneLineTextSize.width - CGFloat(lineCount - 1) * textSize.width
            let endX = self.frame.size.width/2.0 + endWidth/2.0
            
            if endX < rotatePoint.x {
                adjustRotatePoint.y = rotatePoint.y - oneTextSize.height
                adjustRotatePoint.x += fragmentImageView.frame.size.width / 2.0
            }
        }
        
        if currentProgress > LightningStatus.lightning6.progress() {
            if false == fragmentImageView.isAnimating {
                fragmentImageView.animationDuration = Double((1.0 - currentProgress))*duration
                
                var frame = fragmentImageView.frame
                if textCount > oneLineTextCount {
                    frame.origin.x = adjustRotatePoint.x - frame.size.width + 5
                    frame.origin.y = adjustRotatePoint.y - 10
                } else {
                    frame.origin.x = adjustRotatePoint.x - frame.size.width
                    frame.origin.y = adjustRotatePoint.y - 5
                }
                fragmentImageView.frame = frame
                fragmentImageView.startAnimating()
            }
        }
        // end
        UIGraphicsPopContext()
    }
    
}

extension LightningText {
    func rotateWith(_ point: CGPoint, center: CGPoint, angle: Double) -> CGPoint {
        let angleHude = angle * .pi/180 /*角度变成弧度*/
        let cHude = cos(angleHude)
        let sHude = sin(angleHude)
        let xV = Double(point.x - center.x)
        let yV = Double(point.y - center.y)
        
        let x1 = xV * cHude + yV * sHude + Double(center.x)
        let y1 = -xV * sHude + yV * cHude + Double(center.y)
        return CGPoint(x: x1, y: y1)
    }
}
