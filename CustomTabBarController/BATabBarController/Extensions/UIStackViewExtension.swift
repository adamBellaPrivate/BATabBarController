//
//  UIStackViewExtension.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/6/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import UIKit

extension UIStackView {

    func removeAllArrangedViews<T: UIView>(by type: T.Type) {
        arrangedSubviews.forEach({
            if $0 is T {
                $0.removeFromSuperview()
            }
        })
    }

}
