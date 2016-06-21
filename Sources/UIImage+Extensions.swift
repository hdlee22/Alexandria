//
//  UIImage+Extensions.swift
//
//  Created by John C. "Hsoi" Daub (john.daub@ovenbits.com, hsoi@hsoienterprises.com) on 2014-11-04.
//
// The MIT License (MIT)
//
// Copyright (c) 2014-2016 Oven Bits, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

extension UIImage {

    /**
     Returns a copy of self, tinted by the given color.
     
     - parameter tintColor: The UIColor to tint by.
     - returns: A copy of self, tinted by the tintColor.
     */
    public func tinted(_ tintColor: UIColor) -> UIImage {
        guard let cgImage = cgImage else { return self }
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main().scale)

        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()

        tintColor.setFill()

        context?.translate(x: 0, y: size.height)
        context?.scale(x: 1, y: -1)
        context?.setBlendMode(.normal)
        
        let rect = CGRect(origin: .zero, size: size)
        context?.draw(in: rect, image: cgImage)
        
        context?.clipToMask(rect, mask: cgImage)
        context?.addRect(rect)
        context?.drawPath(using: .fill)
        context?.restoreGState()

        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
    /**
     Returns a copy of self, scaled by a specified scale factor (with an optional image orientation).
     
     Example:
     ```
     let image = UIImage(named: <image_name>) // image size = (width: 200, height: 100)
     image?.scaledBy(0.25) // image size = (width: 50, height: 25)
     image?.scaledBy(2)    // image size = (width: 400, height: 200)
     ```
     
     - parameter scaleFactor: The factor at which to scale this image.
     - parameter orientiation: The orientation to use for the scaled image (optional, defaults to the image's `imageOrientation` property).
     - returns: A copy of self, scaled by the scaleFactor (with an optional image orientation).
     */
    public func scaled(by scaleFactor: CGFloat, withOrientation orientation: UIImageOrientation? = nil) -> UIImage? {
        guard let coreImage = cgImage else { return nil }
        
        return UIImage(cgImage: coreImage, scale: 1/scaleFactor, orientation: orientation ?? imageOrientation)
    }

    /**
    Returns an optional image using the `drawingCommands`

    Example:

        let image = UIImage(size: CGSizeMake(12, 24)) {
            let path = UIBezierPath()
            path.moveToPoint(...)
            path.addLineToPoint(...)
            path.addLineToPoint(...)
            path.lineWidth = 2
            UIColor.whiteColor().setStroke()
            path.stroke()
        }

    - parameter size: The image size.
    - parameter drawingCommands: A closure describing the path, fill/stroke color, etc.
    - returns: An optional image based on `drawingCommands`.
    */
    public convenience init?(size: CGSize, drawingCommands commands: () -> Void) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        commands()

        defer { UIGraphicsEndImageContext() }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
        
        self.init(cgImage: image)
    }

    /**
    Returns an optional image using the specified color

    - parameter color: The color of the image.
    - returns: An optional image based on `color`.
    */
    public convenience init?(color: UIColor) {
        let size = CGSize(width: 1, height: 1)
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        color.setFill()
        UIRectFill(rect)

        defer { UIGraphicsEndImageContext() }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
        
        self.init(cgImage: image)
    }
}
