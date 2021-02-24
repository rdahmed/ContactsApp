//
//  TabBarViewController.swift
//  ContactsApp
//
//  Created by Radwa Ahmed on 11/21/20.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set selected controller to Contacts List
        self.selectedIndex = 2
    }
}
