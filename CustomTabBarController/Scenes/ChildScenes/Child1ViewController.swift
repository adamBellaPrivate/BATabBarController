//
//  Child1ViewController.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/5/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import UIKit

class Child1ViewController: UIViewController, BATabBarChildControl {

    weak var baTabBarController: BATabBarController?
    var baTabBarItem: BATabBarItem?

    @IBAction func didTapShowTabBar(_ sender: Any) {
        baTabBarController?.showTabBar()
    }
    
    @IBAction func didTapHideTabBar(_ sender: Any) {
        baTabBarController?.hideTabBar()
    }

}
