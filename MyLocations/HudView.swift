//
//  HudView.swift
//  MyLocations
//
//  Created by 杨宗维 on 2017/7/10.
//  Copyright © 2017年 Icecooll. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    
    class func hudInView(view:UIView, animated:Bool)->HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false

        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.showAnimated(animated: animated)
        return hudView
    }
    override func draw(_ rect: CGRect) {
        let boxWidth:CGFloat = 96
        let boxHeight:CGFloat = 96
        
        let boxRect = CGRect(x: round((bounds.size.width-boxWidth)/2), y: ((round(bounds.size.height)-boxHeight)/2), width: boxWidth, height: boxHeight)
        let roundRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundRect.fill()
        if let image = UIImage(named: "Checkmark"){
           let rect = CGRect(x: center.x-round(image.size.width/2)+20, y: center.y-round(image.size.height/2-boxHeight/8+5), width: 50, height: 50)
            image.draw(in: rect)
            let attribs = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.white ]
            let textSize = text.size(attributes: attribs)
            let textPoint = CGPoint(
                x: center.x - round(textSize.width / 2),
                y: center.y - round(textSize.height / 2) + boxHeight / 4)
            text.draw(at: textPoint, withAttributes: attribs)
        }
    }
    func showAnimated(animated: Bool) { if animated {
        alpha = 0
        transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity })
        }
    }
}
