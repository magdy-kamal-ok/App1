//
//  customTabBarController.swift
//  facebookMessanger
//
//  Created by magdy on 3/10/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
class CustomTabBarController : UITabBarController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        let friendsViewController = FriendsController(collectionViewLayout: layout)
        let recentMessageNavController = UINavigationController(rootViewController: friendsViewController)
       
        recentMessageNavController.tabBarItem.title = "Recent"
        recentMessageNavController.tabBarItem.image = UIImage(named: "recent")


        
        viewControllers = [recentMessageNavController,createDummyNavControllerWithTitle(title: "Call", imageName: "call"),createDummyNavControllerWithTitle(title: "People", imageName: "people"),createDummyNavControllerWithTitle(title: "Settings", imageName: "settings"),createDummyNavControllerWithTitle(title: "Message", imageName: "message")]
    }
    private func createDummyNavControllerWithTitle(title:String,imageName:String)->UINavigationController
    {
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        //recentMessageNavController.navigationBar.isTranslucent = false
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
}
