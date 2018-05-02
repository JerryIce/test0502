//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by 杨宗维 on 2017/7/30.
//  Copyright © 2017年 Icecooll. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    func resizedImageWithBounds(bounds:CGSize)->UIImage{
        let horizontalRatio = bounds.width/size.width
        let verticalRatio = bounds.height/size.height
        let ratio = min(horizontalRatio,verticalRatio)
        let newSize = CGSize(width: size.width*ratio, height: size.height*ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
