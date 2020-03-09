//
//  NSObjectExtension.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/9/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import Foundation

extension NSObject {

    class var nameOfClass: String {
        return String(describing: self)
    }

}
