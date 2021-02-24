//
//  ContactsListViewController.swift
//  ContactsApp
//
//  Created by Radwa Ahmed on 11/21/20.
//

import UIKit

class ContactsListViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var addNewContactButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTemplateLabel: UILabel!
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    
    // Constants
    let noContactsMatchingSearch = "No contacts match you search!"
    let noContactsExist = "No contacts. Press + to add."
    
    // MARK: - Properties
    
    var isSearching = false
    var searchText: String = "" {
        didSet {
            tableView.reloadData()
        }
    }
    
    var contacts = [Contact]()
    var displayContacts: [String: [Contact]] {
        let sorted = contacts.sorted()
        var filtered = sorted
        if isSearching, !searchText.isEmpty {
            filtered = sorted.filter { isMatchingSearch(contact: $0, searchText: searchText) }
        }
        
        return divideContactsIntoGroups(filtered)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchContact()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateContact),
            name: .updateContact,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteContact(_:)),
            name: .deleteContact,
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    // MARK: - Helpers
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView()
        
        navigationItem.searchController = searchController
    }
    
    func fetchContact() {
        
        self.contacts = mockContacts
        tableView.reloadData()
        return
        
        guard let url = URL(string: "https://run.mocky.io/v3/076f4663-4aff-4320-8a60-2cfaf7cc021d") else {
            print("Not valid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["auth": "breer password"]
        request.httpBody = nil
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let apiModels = try JSONDecoder().decode([ContactAPI].self, from: data!)
                let uiModels = apiModels.map { Contact($0) }
                self.contacts = uiModels.sorted()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                print(error)
                // empty template
            }
        }
        
        task.resume()
    }
    
    // Grouping Helpers
    
    private func divideContactsIntoGroups(_ contacts: [Contact]) -> [String: [Contact]] {
        
        var groupedContacts = [String: [Contact]]()
        
        for contact in contacts {
            let groupIndexLetter = getGroupIndexLetter(contact)
            
            if var contacts = groupedContacts[groupIndexLetter] {
                contacts.append(contact)
                groupedContacts[groupIndexLetter] = contacts
            } else {
                groupedContacts[groupIndexLetter] = [contact]
            }
        }
        
        return groupedContacts
    }
    
    private func getGroupIndexLetter(_ contact: Contact) -> String {
        String(contact.firstName?.first ?? contact.lastName?.first ?? "#")
    }
    
    private func getContact(at indexPath: IndexPath) -> Contact? {
        let headers = displayContacts.keys.sorted()
        let targetHeader = headers[indexPath.section]
        let contactsInTargetSection = displayContacts[targetHeader]
        return contactsInTargetSection?[indexPath.row]
    }
    
    // Search Helper
    
    private func isMatchingSearch(contact: Contact, searchText: String) -> Bool {
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let matchingFields = [contact.firstName, contact.lastName, contact.mobile]
            .compactMap { $0 }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.localizedCaseInsensitiveContains(searchText) }

        return !matchingFields.isEmpty
    }
    
    
    // MARK: - Listeners
    
    @objc func updateContact(_ notification: Notification) {
        guard let contact = notification.object as? Contact else { return }
        
        if let index = contacts.firstIndex(of: contact) {
            contacts[index] = contact
        } else {
            contacts.append(contact)
        }
        tableView.reloadData()
    }
    
    @objc func deleteContact(_ notification: Notification) {
        guard let contact = notification.object as? Contact else { return }
        deleteContact(contact: contact)
    }
    
    private func deleteContact(contact: Contact) {
        contacts.removeAll { $0 == contact }
        tableView.reloadData()
    }
}


// MARK: - Navigation

extension ContactsListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController,
           let rootViewController = destination.viewControllers.first as? AddEditContactTableViewController {
            rootViewController.title = "New Contact"
            
        } else if let destination = segue.destination as? ContactDetailsViewController,
                  let indexPath = tableView.indexPathForSelectedRow {
            destination.contact = getContact(at: indexPath)
        }
    }
}


// MARK: - Table View Data Source & Delegate

extension ContactsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return displayContacts.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = displayContacts.isEmpty
        
        let headers = displayContacts.keys.sorted()
        let currentHeader = headers[section]
        
        if isSearching {
            emptyTemplateLabel.text = noContactsMatchingSearch
        } else {
            emptyTemplateLabel.text = noContactsExist
        }
        
        return displayContacts[currentHeader]?.count ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactID", for: indexPath)
        
        let headers = displayContacts.keys.sorted()
        let currentHeader = headers[indexPath.section]
        
        if let contactsInCurrentSection = displayContacts[currentHeader] {
            let contact = contactsInCurrentSection[indexPath.row]
            let fullname = [contact.firstName, contact.lastName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            if fullname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                cell.textLabel?.text = contact.mobile
            } else {
                cell.textLabel?.text = fullname
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let headers = displayContacts.keys.sorted()
        return headers[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
           let contact = getContact(at: indexPath) {
            deleteContact(contact: contact)
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var alphabet = [String]()
        "abcdefghijklmnopqrstuvwxyz#".forEach {
            alphabet.append($0.uppercased())
        }
        return alphabet
    }
        
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
}


// MARK: - Search Bar Delegate

extension ContactsListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchText = ""
        isSearching = false
    }
}
