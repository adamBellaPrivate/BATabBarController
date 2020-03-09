//
//  BATabBarItemAppearance.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/6/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import UIKit

struct BATabBarItemAppearance {

    private enum PrivateConstants {
        enum Appearance {
            static let unselectedTintColor: UIColor = {
                if #available(iOS 13, *) {
                    return UIColor { return $0.userInterfaceStyle == .dark ? .white : .black }
                } else {
                    return .black
                }
            }()
            static let selectedTintColor: UIColor = .red
            static let textFont = UIFont.boldSystemFont(ofSize: 12)
        }
    }

    private static let singleton = BATabBarItemAppearance()
    static func appearance() -> BATabBarItemAppearance {
        return singleton
    }

    var unselectedTintColor = PrivateConstants.Appearance.unselectedTintColor
    var selectedTintColor = PrivateConstants.Appearance.selectedTintColor
    var textFont = PrivateConstants.Appearance.textFont

}
