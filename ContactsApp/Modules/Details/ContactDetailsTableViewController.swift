//
//  ContactDetailsTableViewController.swift
//  ContactsApp
//
//  Created by Radwa Ahmed on 11/28/20.
//

import UIKit
import MessageUI

class ContactDetailsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    // MARK:  IBOutlets
    
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var iCloudLabel: UILabel!
    
    // MARK: - Properties
    
    var contact: Contact?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let contact = contact {
            setupUI(with: contact)
        }
    }
    
    func update(_ contact: Contact) {
        setupUI(with: contact)
    }
    
    // MARK: - Helpers
    
    private func setupUI(with contact: Contact) {
        mobileLabel.text = contact.mobile
        iCloudLabel.text = contact.email
    }
    
    
    // MARK: - IBActions & Communications
    
    @IBAction func didTapCall(_ sender: Any) {
        if let mobile = contact?.mobile {
            if let callURL = URL(string: "tel://" + mobile) {
                let application = UIApplication.shared
                
                if application.canOpenURL(callURL) {
                    application.open(callURL, options:[:], completionHandler: nil)
                }
            }
        }
    }
    
    
    @IBAction func didTapSendMail(_ sender: Any) {
        guard
            let email = contact?.email,
            MFMailComposeViewController.canSendMail()
        else { return }
        
        let composeViewController = MFMailComposeViewController()
        composeViewController.mailComposeDelegate = self
        composeViewController.setToRecipients([email])
                
        self.present(composeViewController, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true)
    }
    
}


// MARK: - Table View Delegate

extension ContactDetailsTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return .leastNonzeroMagnitude
        }
        return 28
    }
}

