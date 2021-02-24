//
//  ContactDetailsViewController.swift
//  ContactsApp
//
//  Created by Radwa Ahmed on 11/27/20.
//

import UIKit
import MessageUI

class ContactDetailsViewController: UIViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var editContactDetailsButton: UIBarButtonItem!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var messageView: CommunicationView!
    @IBOutlet weak var callView: CommunicationView!
    @IBOutlet weak var videoView: CommunicationView!
    @IBOutlet weak var emailView: CommunicationView!
    private var tableViewController: ContactDetailsTableViewController?
    
    // MARK: - Properties
    
    var contact: Contact?
    private let placeholderImage = UIImage(systemName: "person.crop.circle.fill")
    private let messageImage = UIImage(systemName: "message.fill")
    private let callImage = UIImage(systemName: "phone.fill")
    private let videoImage = UIImage(systemName: "video.fill")
    private let emailImage = UIImage(systemName: "envelope.fill")
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupObservers()
        
        if let contact = contact {
            setupUI(with: contact)
        } else {
            contactImageView.image = placeholderImage
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateContact),
            name: .updateContact,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteContact),
            name: .deleteContact,
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    
    private func setupViews() {
        contactImageView.layer.cornerRadius = contactImageView.frame.height / 2
        contactImageView.clipsToBounds = true
        
        messageView.configure(messageImage, title: "message")
        messageView.delegate = self
        
        callView.configure(callImage, title: "call")
        callView.delegate = self
        
        videoView.configure(videoImage, title: "video")
        videoView.delegate = self
        
        emailView.configure(emailImage, title: "email")
        emailView.delegate = self
    }
    
    private func setupUI(with contact: Contact) {
        if let image = contact.image {
            contactImageView.image = image
        } else {
            contactImageView.image = placeholderImage
        }
        
        messageView.setEnabled(contact.mobile != nil)
        callView.setEnabled(contact.mobile != nil)
        emailView.setEnabled(contact.email != nil)
        
        let fullName = [contact.firstName, contact.lastName].compactMap { $0 }.joined(separator: " ")
        fullNameLabel.text = fullName
    }
    
    @objc func updateContact(_ notification: Notification) {
        guard let contact = notification.object as? Contact else { return }
        self.contact = contact
        setupUI(with: contact)
        tableViewController?.update(contact)
    }
    
    @objc func deleteContact(_ notification: Notification) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - IBActions & Communications
    
    private func didTapSendMessage() {
        let composeViewController = MFMessageComposeViewController()
        composeViewController.messageComposeDelegate = self
        composeViewController.recipients = [(contact?.mobile)!]
        
        self.present(composeViewController, animated: true)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true)
    }
    
    
    private func didTapCall() {
        if let callURL = URL(string: "tel://" + (contact?.mobile)!) {
            let application = UIApplication.shared
            
            if application.canOpenURL(callURL) {
                application.open(callURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    private func didTapSendMail() {
        guard let email = contact?.email else { return }
        
        let composeViewController = MFMailComposeViewController()
        composeViewController.mailComposeDelegate = self
        composeViewController.setToRecipients([email])
        
        self.present(composeViewController, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true)
    }
}


// MARK: - Navigation

extension ContactDetailsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController,
           let rootViewController = destination.viewControllers.first as? AddEditContactTableViewController {
            
            destination.modalTransitionStyle = .crossDissolve
            destination.modalPresentationStyle = .fullScreen
            
            rootViewController.contact = self.contact
            
        } else if let destination = segue.destination as? ContactDetailsTableViewController {
            
            tableViewController = destination
            destination.contact = self.contact
        }
    }
    
}

extension ContactDetailsViewController: CommunicationViewDelegate {
    func communicationViewDidTap(_ view: CommunicationView) {
        switch view {
        case messageView:
            didTapSendMessage()
        case callView:
            didTapCall()
        case emailView:
            didTapSendMail()
        
        default:
            break
        }
    }
}
