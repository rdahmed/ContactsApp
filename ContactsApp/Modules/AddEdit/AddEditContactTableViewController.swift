//
//  AddEditContactTableViewController.swift
//  ContactsApp
//
//  Created by Radwa Ahmed on 11/27/20.
//

import UIKit

class AddEditContactTableViewController: UITableViewController, UISearchTextFieldDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var deleteContactButton: UIButton!
    
    // MARK: - Properties
    
    var contact: Contact!
    var isNewContact = false
    let tableViewSections = TableViewSections()
    let imagePicker = UIImagePickerController()
    private let placeholderImage = UIImage(systemName: "person.crop.circle.fill")
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableDoneBarButton()
        setupViews()
        setupImagePicker()
        
        if let contact = contact {
            setupUI(with: contact)
        } else {
            // Create new contact
            contact = Contact()
            isNewContact = true
        }
    }
    
    // MARK: - Helpers
    
    @objc func doneUpdating(_ textField: UITextField) {
//        string.trimmingCharacters(in: .whitespacesAndNewlines)
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }

        guard
            let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let mobileNumber = mobileNumberTextField.text,
            let email = emailTextField.text,
            !firstName.isEmpty || !lastName.isEmpty
            || !mobileNumber.isEmpty || !email.isEmpty
        else {
            doneBarButton.isEnabled = false
            return
        }
        doneBarButton.isEnabled = true
    }

    private func enableDoneBarButton() {
        [firstNameTextField, lastNameTextField, mobileNumberTextField, emailTextField]
            .forEach({ $0?.addTarget(self, action: #selector(doneUpdating), for: .editingChanged) })
    }
    
    private func setupViews() {
        contactImageView.layer.cornerRadius = contactImageView.frame.height / 2
    }
    
    private func setupUI(with contact: Contact) {
        if let image = contact.image {
            contactImageView.image = image
        } else {
            contactImageView.image = placeholderImage
        }
        
        firstNameTextField.text = contact.firstName
        lastNameTextField.text = contact.lastName
        mobileNumberTextField.text = contact.mobile
        emailTextField.text = contact.email
        notesTextView.text = contact.notes
    }
    
    private func setupImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .fullScreen
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        contact.image = contactImageView.image
        contact.firstName = firstNameTextField.text
        contact.lastName = lastNameTextField.text
        contact.mobile = mobileNumberTextField.text
        contact.email = emailTextField.text
        contact.notes = notesTextView.text
        
        NotificationCenter.default.post(name: .updateContact, object: contact)
        dismiss(animated: true)
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func deleteContact(_ sender: Any) {
        let title = "Are you sure?"
        let message = "You cannot undo this action"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { [self] action in
                NotificationCenter.default.post(name: .deleteContact, object: contact)
                dismiss(animated: true)
            }
        )
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
}


// MARK: - Image picker

extension AddEditContactTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            contactImageView.image = photo
            dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - Table View Delegate

extension AddEditContactTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        if indexPath.section == tableViewSections.profilePictureSection {
            return 200
        } else if indexPath.section == tableViewSections.deleteContactSection, isNewContact {
            return .zero
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == tableViewSections.profilePictureSection
            || (section == tableViewSections.deleteContactSection && isNewContact) {
            return .leastNonzeroMagnitude
        }
        return 28
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    
        if section == tableViewSections.deleteContactSection - 1 && isNewContact {
            return .leastNonzeroMagnitude
        }
        return 28
    }
}
