//
//  String+AddText.swift
//  MyLocations
//
//  Created by 杨宗维 on 2017/7/31.
//  Copyright © 2017年 Icecooll. All rights reserved.
//

import Foundation
extension String{
    mutating func addText(text:String?,withSeparator separator:String = ""){
        if let text = text {
            if !isEmpty{
                self += separator
            }
            self += text
        }
    }
}
