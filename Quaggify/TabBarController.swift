//
//  TabBarController.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
  
  var previousViewController: UIViewController?
  
  var didLogin = false
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    delegate = self
    
    UITabBar.appearance().tintColor = ColorPalette.white
    UITabBar.appearance().isTranslucent = false
    UITabBar.appearance().barTintColor = ColorPalette.gray
    
    // Fetching updated user
    if !didLogin {
      if let user = User.getFromDefaults() {
        User.current = user
      }
      API.fetchCurrentUser { (user, error) in
        if let user = user {
          User.current = user
          User.current.saveToDefaults()
        }
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let homeViewController = NavigationController(rootViewController: HomeViewController())
    let homeIcon = #imageLiteral(resourceName: "tab_icon_home").withRenderingMode(.alwaysTemplate)
    let homeIconFilled = #imageLiteral(resourceName: "tab_icon_home_filled").withRenderingMode(.alwaysTemplate)
    homeViewController.tabBarItem = UITabBarItem(title: "Home", image: homeIcon, selectedImage: homeIconFilled)
    homeViewController.tabBarItem.tag = 0
    
    if previousViewController == nil {
      previousViewController = homeViewController
    }
    
    let searchViewController = NavigationController(rootViewController: SearchViewController())
    let searchIcon = #imageLiteral(resourceName: "tab_icon_search").withRenderingMode(.alwaysTemplate)
    searchViewController.tabBarItem = UITabBarItem(title: "Search", image: searchIcon, tag: 1)
    
    let libraryViewController = NavigationController(rootViewController: LibraryViewController())
    let libraryIcon = #imageLiteral(resourceName: "tab_icon_library").withRenderingMode(.alwaysTemplate)
    let libraryIconFilled = #imageLiteral(resourceName: "tab_icon_library_filled").withRenderingMode(.alwaysTemplate)
    libraryViewController.tabBarItem = UITabBarItem(title: "Your Library", image: libraryIcon, selectedImage: libraryIconFilled)
    libraryViewController.tabBarItem.tag = 2
    
    viewControllers = [homeViewController, searchViewController, libraryViewController]
  }
  
}

extension TabBarController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    if previousViewController == viewController {
      if let navController = viewController as? NavigationController {
        if let homeVC = navController.topViewController as? HomeViewController {
          homeVC.scrollToTop()
        }
        if let searchVC = navController.topViewController as? SearchViewController {
          searchVC.scrollToTop()
        }
        if let libraryVC = navController.topViewController as? LibraryViewController {
          libraryVC.scrollToTop()
        }
      }
    }
    previousViewController = viewController
  }
}















