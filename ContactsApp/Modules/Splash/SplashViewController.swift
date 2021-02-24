//
//  SplashViewController.swift
//  ContactsApp
//
//  Created by Radwa Ahmed on 11/20/20.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet var logoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Prepare Animation
        logoLabel.transform = CGAffineTransform.identity.scaledBy(x: .leastNonzeroMagnitude, y: .leastNonzeroMagnitude)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Excute Animation
        UIView.animate(withDuration: 1) {
            self.logoLabel.transform = CGAffineTransform.identity
        } completion: { _ in
            self.performSegue(withIdentifier: "tabBarSegue", sender: nil)
        }
    }

}

    
    
   /* override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logoLabel.transform = CGAffineTransform.identity.scaledBy(x: .leastNonzeroMagnitude, y: .leastNonzeroMagnitude)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1) {
            self.logoLabel.transform = CGAffineTransform.identity
        } completion: { _ in
            self.performSegue(withIdentifier: "listSegue", sender: nil)
        }
    } */


