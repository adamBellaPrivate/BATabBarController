//
//  BATabBarControlAppearance.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/6/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import UIKit

struct BATabBarControlAppearance {

    private enum PrivateConstants {
        enum Appearance {
            static let backgroundColor: UIColor = {
                if #available(iOS 13, *) {
                    return UIColor { return $0.userInterfaceStyle == .dark ? .black : .white }
                } else {
                    return .white
                }
            }()
        }
    }

    private static let singleton = BATabBarControlAppearance()
    static func appearance() -> BATabBarControlAppearance {
        return singleton
    }

    var backgroundColor = PrivateConstants.Appearance.backgroundColor

}
