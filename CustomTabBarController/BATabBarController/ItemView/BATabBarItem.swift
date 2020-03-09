//
//  BATabBarItem.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/5/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import UIKit

class BATabBarItem: UIView {
    
    typealias TabBarItemCallback = (BATabBarItem) -> Void

    // MARK: - Outlets

    @IBOutlet private weak var lblTitle: UILabel!
    @IBOutlet private weak var imgIcon: UIImageView!

    // MARK: - Public properties

    var onClickHandler: TabBarItemCallback?
    var isSelected = false {
        didSet {
            updateSelectedState()
        }
    }

    // MARK: - Private properties

    private var image: UIImage?
    private var selectedImage: UIImage?

    // MARK: - Lifecycle functions

    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

         commonInit()
    }

    public static func instantiate(title: String? = .none,
                                   image: UIImage? = .none,
                                   selectedImage: UIImage? = .none) -> BATabBarItem {
        let contentView: BATabBarItem = BATabBarItem.fromNib()
        contentView.selectedImage = selectedImage
        contentView.image = image
        contentView.imgIcon.image = image
        contentView.lblTitle.text = title
        return contentView
    }

}

private extension BATabBarItem {

    var tabBarTintColor: UIColor {
        return isSelected ? BATabBarItemAppearance.appearance().selectedTintColor : BATabBarItemAppearance.appearance().unselectedTintColor
    }

    // MARK: - Comon init

    final func commonInit() {
        addTapGesture()
        performStyle()
    }

    // MARK: - Style

    final func performStyle() {
        lblTitle.textColor = tabBarTintColor
        imgIcon.tintColor = tabBarTintColor
        lblTitle.font = BATabBarItemAppearance.appearance().textFont
    }

    final func updateSelectedState() {
        performStyle()
        guard let selectedImage = selectedImage else { return }
        imgIcon?.image = isSelected ? selectedImage : image
    }

    // MARK: - Tap gesture

    final func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGesture)
    }

    @objc func didTapView() {
        onClickHandler?(self)
    }

}
