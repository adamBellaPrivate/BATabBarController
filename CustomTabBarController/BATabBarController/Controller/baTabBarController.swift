//
//  BATabBarController.swift
//  CustomTabBarController
//
//  Created by Bella Ádám on 3/5/20.
//  Copyright © 2020 Bella Ádám. All rights reserved.
//

import UIKit

class BATabBarController: UIViewController {

    private enum PrivateConstants {
        static let animationSpeed: TimeInterval = 0.3
        static let maxTabCountWithoutMenu = 5
        static let maxTabCountWithMenu = 4

        enum MenuDefaultValues {
            static let maxMenuShadowAlpha: CGFloat = 0.5
            static let menuAnimationDuration: TimeInterval = 0.3
            static let menuPortraitOpenedPadding: CGFloat = 70.0
            static let menuLandscapeOpenedPadding: CGFloat = 120.0
            static let canUseMenuSelectedAppearance = true
        }
    }

    // MARK: - Outlets

    @IBOutlet private weak var constraintStackBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintMenuBottom: NSLayoutConstraint!
    @IBOutlet private weak var viewContentContainer: UIView!
    @IBOutlet private weak var stackMenu: UIStackView!

    // MARK: - Menu outlets

    @IBOutlet private weak var viewMenuShadow: UIView!
    @IBOutlet private weak var viewMenuContainer: UIView!
    @IBOutlet private weak var menuWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var constraintMenuTrailing: NSLayoutConstraint!

    // MARK: - Public properties

    var isMenuEdgeGestureEnabled = true
    var isShadowCloseGestureEnabled = true
    var isMenuSwipeGestureEnabled = true
    private(set) var isMenuOpen = false
    let viewControllers = BATabBarObserver<[BATabBarChildControl]>([])
    let menuViewController = BATabBarObserver<BATabBarChildControl?>(.none)

    // MARK: - Delegates & DataSources

    weak var menuDelegate: BATabBarMenuDelegate?

    // MARK: - Private properties

    private(set) var selectedViewController: BATabBarChildControl?
    private var hasSlideMenu = false
    private var edgePanGesture: UIScreenEdgePanGestureRecognizer?

    // MARK: - Lifecycle functions

    override func viewDidLoad() {
        super.viewDidLoad()

        performStyle()
        setupSideMenu()
        subscribeToDataObservers()
    }

    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        constraintStackBottom.constant = self.view.safeAreaInsets.bottom
        updateMenuFrame()

        constraintMenuTrailing.constant = isMenuOpen ? 0 : -menuWidthConstraint.constant
        view.layoutIfNeeded()
    }

    // MARK: - Public functions

    final func showTabBar(with animated: Bool = true) {
        runAnimation(with: 0, animated: animated)
    }

    final func hideTabBar(with animated: Bool = true) {
        runAnimation(with: -(stackMenu.superview?.bounds.size.height ?? 0), animated: animated)
    }

    // MARK: - Gesture behaviour controls

    final func enableAllMenuGestures() {
        isMenuEdgeGestureEnabled = true
        isMenuSwipeGestureEnabled = true
        isShadowCloseGestureEnabled = true
    }

    final func blockAllMenuGestures() {
        isMenuEdgeGestureEnabled = false
        isMenuSwipeGestureEnabled = false
        isShadowCloseGestureEnabled = false
    }

    // MARK: - Menu visibility controls

    final func toggleMenu() {
        guard isMenuOpen else {
            openMenu()
            return
        }
        closeMenu()
    }

}

private extension BATabBarController {

    var menuSwipeAnimationDuration: TimeInterval {
        let expectedanimationDuration = menuDelegate?.menuSwipeAnimationDuration?() ?? PrivateConstants.MenuDefaultValues.menuAnimationDuration
        return max(expectedanimationDuration, 0.2)
    }

    var menuMaxShadowAlpha: CGFloat {
        let expectedMaxAlpha = menuDelegate?.menuMaxShadowAlpha?() ?? PrivateConstants.MenuDefaultValues.maxMenuShadowAlpha
        return min(max(0, expectedMaxAlpha), 1)
    }

    var maxTabCount: Int {
       return !hasSlideMenu ? PrivateConstants.maxTabCountWithoutMenu : PrivateConstants.maxTabCountWithMenu
    }

    var canUseMenuSelectedAppearance: Bool {
        return menuDelegate?.canUseMenuSelectedAppearance?() ?? PrivateConstants.MenuDefaultValues.canUseMenuSelectedAppearance
    }

    // MARK: - Style

    final func performStyle() {
        stackMenu.superview?.backgroundColor = BATabBarControlAppearance.appearance().backgroundColor
    }

    // MARK: - Observers

    final func subscribeToDataObservers() {
        viewControllers.bindAndFire { [weak self] tabBarControllers in
            tabBarControllers.forEach({
                $0.baTabBarItem?.onClickHandler = { [weak self] tabItem in
                    self?.selectTab(by: tabItem)
                }
            })
            self?.updateTabBarItems()
        }
        menuViewController.bindAndFire { [weak self] menuTabBarcontroller in
            menuTabBarcontroller?.baTabBarItem?.onClickHandler = { [weak self] _ in
                self?.toggleMenu()
            }
            self?.loadMenuViewController()
        }
    }

    // MARK: - Tab bar animation

    final func runAnimation(with constant: CGFloat, animated: Bool) {
        constraintMenuBottom.constant = constant
        guard animated else {
            view.layoutIfNeeded()
            return
        }
        DispatchQueue.main.async {
            UIView.animate(withDuration: PrivateConstants.animationSpeed) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }

    // MARK: - Updated tab bar

    final func updateTabBarItems() {
        stackMenu.removeAllArrangedViews(by: UIView.self)
        viewControllers.value.filter { $0.baTabBarItem != .none }.prefix(maxTabCount).forEach {
            $0.baTabBarController = self
            stackMenu.addArrangedSubview($0.baTabBarItem!)
        }

        if let menuTabBarItem = menuViewController.value?.baTabBarItem {
            stackMenu.addArrangedSubview(menuTabBarItem)
        }


        var shouldSetDefault = true
        if let currentTabBarItem = selectedViewController?.baTabBarItem {
            shouldSetDefault = !stackMenu.arrangedSubviews.contains(currentTabBarItem)
        }

        if shouldSetDefault, let target = viewControllers.value.first(where: { $0.baTabBarItem != nil }) {
            selectViewController(with: target)
        }
    }

    // MARK: - Menu load/unload

    final func loadMenuViewController() {
        unloadMenuViewController()
        guard let menuViewController = menuViewController.value, menuViewController.baTabBarItem != .none else { return }
        menuViewController.willMove(toParent: self)
        menuViewController.view.frame = viewMenuContainer.bounds
        menuViewController.view.layoutIfNeeded()
        viewMenuContainer.addAndAnchorSubView(menuViewController.view)
        addChild(menuViewController)
        menuViewController.didMove(toParent: self)
        menuViewController.baTabBarController = self
        hasSlideMenu = true

    }

    final func unloadMenuViewController() {
        closeMenu()
        updateTabBarItems()
        menuViewController.value?.willMove(toParent: .none)
        menuViewController.value?.view.removeFromSuperview()
        menuViewController.value?.removeFromParent()
        hasSlideMenu = false
    }

    // MARK: - Content manager

    final func selectTab(by tabItem: BATabBarItem) {
        guard !isMenuOpen, let target = viewControllers.value.first(where: { $0.baTabBarItem == tabItem }) else { return }
        selectViewController(with: target)
    }

    final func performTabItemStyle(with baTabBarItem: BATabBarItem?) {
        viewControllers.value.forEach({ $0.baTabBarItem?.isSelected = $0.baTabBarItem == baTabBarItem })
        menuViewController.value?.baTabBarItem?.isSelected = menuViewController.value?.baTabBarItem == baTabBarItem
    }

    final func selectViewController(with target: BATabBarChildControl) {
        if let currentViewController = selectedViewController, currentViewController == target {
            if let navigationController = currentViewController as? UINavigationController {
                navigationController.popToRootViewController(animated: true)
            }
            return
        }
        performTabItemStyle(with: target.baTabBarItem)

        selectedViewController?.willMove(toParent: .none)
        selectedViewController?.view.removeFromSuperview()
        selectedViewController?.removeFromParent()

        selectedViewController = target
        target.willMove(toParent: self)
        target.view.frame = viewContentContainer.bounds
        target.view.layoutIfNeeded()
        viewContentContainer.addAndAnchorSubView(selectedViewController?.view)
        addChild(target)
        target.didMove(toParent: self)
    }

    // MARK: - Setup side menu view

    func setupSideMenu() {
        updateMenuFrame()
        constraintMenuTrailing.constant = -menuWidthConstraint.constant
        viewMenuShadow.alpha = 0.0
        viewMenuShadow.isHidden = true

        addEdgeGesture(to: view)
        addTapGesture(to: viewMenuShadow)
        addPanGesture(to: viewMenuShadow)
    }

    final func updateMenuFrame() {
        var defaultPadding = PrivateConstants.MenuDefaultValues.menuPortraitOpenedPadding
        var padding = menuDelegate?.menuMaxPortraitOpenedPadding?() ?? defaultPadding
        if UIDevice.current.orientation.isLandscape {
            defaultPadding = PrivateConstants.MenuDefaultValues.menuLandscapeOpenedPadding
            padding = menuDelegate?.menuMaxLandscapeOpenedPadding?() ?? defaultPadding
        }
        var screenWidth = UIScreen.main.bounds.width
        if #available(iOS 11.0, *), let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets {
            screenWidth -= safeAreaInsets.left
            screenWidth -= safeAreaInsets.right
        }

        let expectedPadding = min(max(padding, defaultPadding), screenWidth * 0.4)
        menuWidthConstraint.constant = screenWidth - expectedPadding
    }

    // MARK: Side menu's controls

    final func openMenu() {
        guard hasSlideMenu else { return }

        if canUseMenuSelectedAppearance {
            performTabItemStyle(with: menuViewController.value?.baTabBarItem)
        }

        // MARK: - Calculate animation speed ration
        let percent = abs(Double(constraintMenuTrailing.constant / menuWidthConstraint.constant))

        // when menu is opened, it's right constraint should be 0
        constraintMenuTrailing.constant = 0

        // view for dimming effect should also be shown
        viewMenuShadow.isHidden = false

        // animate opening of the menu - including opacity value

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: self.menuSwipeAnimationDuration * percent, animations: { [weak self] in
                guard let self = self else { return }
                self.view.layoutIfNeeded()
                self.viewMenuShadow.alpha = self.menuMaxShadowAlpha
            }, completion: { [weak self] isFinished in
                guard isFinished else { return }
                // disable the screen edge pan gesture when menu is fully opened
                self?.edgePanGesture?.isEnabled = false
                self?.isMenuOpen = true
            })
        }
    }

    final func closeMenu() {
        guard hasSlideMenu else { return }

        if canUseMenuSelectedAppearance {
            performTabItemStyle(with: selectedViewController?.baTabBarItem)
        }

        // MARK: - Calculate animation speed ration
        let percent = 1 - abs(Double(constraintMenuTrailing.constant / menuWidthConstraint.constant))

        constraintMenuTrailing.constant = -menuWidthConstraint.constant

        // animate closing of the menu - including opacity value

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: self.menuSwipeAnimationDuration * percent, animations: { [weak self] in
                self?.view.layoutIfNeeded()
                self?.viewMenuShadow.alpha = 0
            }, completion: { [weak self] isFinished in
                guard isFinished else { return }

                // reenable the screen edge pan gesture so we can detect it next time
                self?.edgePanGesture?.isEnabled = true

                // hide the view for dimming effect so it wont interrupt touches for views underneath it
                self?.viewMenuShadow.isHidden = true
                self?.isMenuOpen = false
            })
        }
    }

    // MARK: - Menu gesture setup functions

    final func addEdgeGesture(to view: UIView?) {
        edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(didPanEdge(_:)))
        edgePanGesture?.edges = .right
        guard let edgePanGesture = edgePanGesture else { return }
        view?.addGestureRecognizer(edgePanGesture)
    }

    final func addTapGesture(to view: UIView?) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view?.addGestureRecognizer(tapGesture)
    }

    final func addPanGesture(to view: UIView?) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didDragView(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        view?.addGestureRecognizer(panGesture)
    }

    // MARK: - Menu handler of gesture

    @objc
    func didTapView() {
        guard hasSlideMenu, isShadowCloseGestureEnabled else { return }
        closeMenu()
    }

    @objc
    func didPanEdge(_ sender: UIScreenEdgePanGestureRecognizer) {
        guard hasSlideMenu, isMenuEdgeGestureEnabled else { return }
        if sender.state == UIGestureRecognizer.State.began {
            // if the user has just started dragging, make sure view for dimming effect is hidden well
            viewMenuShadow.isHidden = false
            viewMenuShadow.alpha = 0.0
        } else if sender.state == UIGestureRecognizer.State.changed {
            // retrieve the amount viewMenu has been dragged
            let translationX = abs(sender.translation(in: sender.view).x)
            if translationX > 0.0, translationX < menuWidthConstraint.constant {
                constraintMenuTrailing.constant = -menuWidthConstraint.constant + translationX
                let ratio = translationX / menuWidthConstraint.constant
                let alphaValue = ratio * menuMaxShadowAlpha
                viewMenuShadow.alpha = alphaValue
            }
        } else {
            // if the menu was dragged less than half of it's width, close it. Otherwise, open it.
            if abs(constraintMenuTrailing.constant) > menuWidthConstraint.constant / 2 {
                closeMenu()
            } else {
                openMenu()
            }
        }
    }

    @objc
    func didDragView(_ sender: UIPanGestureRecognizer) {
        guard hasSlideMenu, isMenuSwipeGestureEnabled else { return }
        // retrieve the current state of the gesture
        if sender.state == UIGestureRecognizer.State.began {
            // no need to do anything
        } else if sender.state == UIGestureRecognizer.State.changed {
            // retrieve the amount viewMenu has been dragged
            let translationX = sender.translation(in: sender.view).x
            if translationX > 0.0, translationX < menuWidthConstraint.constant {
                // it's being dragged somewhere between min and max amount
                constraintMenuTrailing.constant = -translationX

                let ratio = (menuWidthConstraint.constant - translationX) / menuWidthConstraint.constant
                let alphaValue = ratio * menuMaxShadowAlpha
                viewMenuShadow.alpha = alphaValue
            }
        } else {
            // if the drag was less than half of it's width, close it. Otherwise, open it.
            if abs(constraintMenuTrailing.constant) > menuWidthConstraint.constant / 2 {
                closeMenu()
            } else {
                openMenu()
            }
        }
    }

}
