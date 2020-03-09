//
//  BATabBarMenuDelegate.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/6/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import UIKit

@objc protocol BATabBarMenuDelegate: class {

    @objc optional func menuMaxPortraitOpenedPadding() -> CGFloat
    @objc optional func menuMaxLandscapeOpenedPadding() -> CGFloat
    @objc optional func menuMaxShadowAlpha() -> CGFloat
    @objc optional func menuSwipeAnimationDuration() -> TimeInterval
    @objc optional func canUseMenuSelectedAppearance() -> Bool
    
}
