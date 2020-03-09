//
//  ChildNavigationController.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/6/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import UIKit

class ChildNavigationController: UINavigationController, BATabBarChildControl {

    weak var baTabBarController: BATabBarController?
    weak var baTabBarItem: BATabBarItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        interactivePopGestureRecognizer?.isEnabled = false
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)

        baTabBarController?.blockAllMenuGestures()
        baTabBarController?.hideTabBar(with: animated)
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let poppedViewControllers = super.popToRootViewController(animated: animated)
        baTabBarController?.enableAllMenuGestures()
        baTabBarController?.showTabBar(with: animated)
        return poppedViewControllers
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let poppedViewController = super.popViewController(animated: animated)
        if viewControllers.count == 1 {
            baTabBarController?.enableAllMenuGestures()
            baTabBarController?.showTabBar(with: animated)
        }
        return poppedViewController
    }

    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let poppedViewControllers = super.popToViewController(viewController, animated: animated)
        if viewControllers.count == 1 {
            baTabBarController?.enableAllMenuGestures()
            baTabBarController?.showTabBar(with: animated)
        }
        return poppedViewControllers
    }

}
