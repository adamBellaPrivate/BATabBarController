//
//  BATabBarObserver.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/6/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import Foundation

class BATabBarObserver<T> {
    typealias Listener = (T) -> Void

    // MARK: - Private properties

    private var listener: Listener?

    // MARK: - Public properties

    var value: T {
        didSet {
            listener?(value)
        }
    }

    // MARK: - Lifecycle functions

    init(_ initValue: T) {
        value = initValue
    }

    // MARK: - Public functions

    final func bind(_ newListener: @escaping Listener) {
       listener = newListener
    }

    final func bindAndFire(_ newListener: @escaping Listener) {
        listener = newListener
        fire()
    }

}

private extension BATabBarObserver {

    final func fire() {
        listener?(value)
    }
    
}
