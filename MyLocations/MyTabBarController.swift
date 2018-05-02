//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by 杨宗维 on 2017/8/1.
//  Copyright © 2017年 Icecooll. All rights reserved.
//

import Foundation
import UIKit
class MyTabBarController:UITabBarController{
    override var preferredStatusBarStyle:UIStatusBarStyle {
        return .lightContent
    }
    override var childViewControllerForStatusBarStyle: UIViewController?{
        return nil
    }
}
