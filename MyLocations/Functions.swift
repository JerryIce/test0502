//
//  Functions.swift
//  MyLocations
//
//  Created by 杨宗维 on 2017/7/11.
//  Copyright © 2017年 Icecooll. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(seconds:Double, closure: @escaping ()->()){
    let when = DispatchTime.now()+seconds
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
let applicationDocumentsDirectory:String = {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }()
