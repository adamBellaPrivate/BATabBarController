//
//  AppDelegate.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/5/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let tabBarController = BATabBarController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        setupTestControllers()
        return true
    }

    // MAR: For testing

    final func setupTestControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        let simpleChild1 = storyboard.instantiateViewController(withIdentifier: "Child1ViewController") as! BATabBarChildControl
        simpleChild1.baTabBarItem = BATabBarItem.instantiate(title: "title1",
                                                     image: UIImage(named: "stream")?.withRenderingMode(.alwaysOriginal))

        let simpleChild2 = storyboard.instantiateViewController(withIdentifier: "Child3ViewController") as! BATabBarChildControl
        simpleChild2.baTabBarItem = BATabBarItem.instantiate(title: "title2",
                                                     image: UIImage(named: "rent")?.withRenderingMode(.alwaysOriginal),
                                                     selectedImage: UIImage(named: "rent")?.withRenderingMode(.alwaysTemplate))

        let navChild = storyboard.instantiateViewController(withIdentifier: "ChildNavigationController") as! BATabBarChildControl
        navChild.baTabBarItem = BATabBarItem.instantiate(title: "NavEx",
                                                         image: UIImage(named: "stream")?.withRenderingMode(.alwaysOriginal))


        tabBarController.viewControllers.value = [simpleChild1, simpleChild2, navChild]

        let menuChild = storyboard.instantiateViewController(withIdentifier: "Child2ViewController") as! BATabBarChildControl
        menuChild.baTabBarItem = BATabBarItem.instantiate(title: "Menu",
                                                     image: UIImage(named: "home")?.withRenderingMode(.alwaysTemplate))

        tabBarController.menuViewController.value = menuChild
    }

}

