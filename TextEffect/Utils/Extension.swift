//
//  Extension.swift
//  HOTextEffect
//
//  Created by Holaween on 2018/10/6.
//  Copyright © 2018年 OldDaddy0. All rights reserved.
//

import Foundation
import UIKit

extension NSString {
    // MARK: size
    func displaySizeWith(font: UIFont, width: CGFloat, height: CGFloat) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let size = CGSize(width: width, height: height)
        
        let frame = boundingRect(with: size, options:[.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil).integral
        
        return CGSize(width: frame.size.width, height: frame.size.height)
    }
    
    func singleLineSize(_ font: UIFont) -> CGSize {
        return displaySizeWith(font: font, width: CGFloat.greatestFiniteMagnitude, height: font.lineHeight)
    }
    
    // MARK: length
    func textCount() -> Int {
        var count: Int = 0
        enumerateSubstrings(in: NSRange(location: 0, length: self.length), options: NSString.EnumerationOptions.byComposedCharacterSequences) { (substring, substringRange, enclosingRange, stop) in
            count = count + 1
        }
        
        return count
    }
    
    // MARK:
    class func cnTextSize(_ font: UIFont) -> CGSize {
        return NSString(string: "国").displaySizeWith(font: font, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
}
