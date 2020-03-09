//
//  UIViewExtension.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/6/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import UIKit

extension UIView {

    class func fromNib<T: UIView>() -> T {
        let contentView = Bundle.main.loadNibNamed(nameOfClass, owner: nil, options: nil)!.first as! T
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }

    func addAndAnchorSubView(_ view: UIView?) {
        guard let view = view else { return }
        self.addSubview(view)
        self.anchorAll(to: view)
    }

    func anchorAll(to view: UIView) {
        leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
