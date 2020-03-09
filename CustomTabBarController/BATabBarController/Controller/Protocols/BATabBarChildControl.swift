//
//  BATabBarChildControl.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/6/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import UIKit

protocol BATabBarChildControl: UIViewController {

    var baTabBarItem: BATabBarItem? { set get }
    var baTabBarController: BATabBarController? { set get }
    
}
