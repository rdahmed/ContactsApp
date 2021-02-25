//
//  Contact.swift
//  ContactsApp
//
//  Created by Radwa Ahmed on 11/26/20.
//

import Foundation
import UIKit

struct Contact: Comparable, Hashable {

    var id: String
    var firstName: String?
    var lastName: String?
    var image: UIImage?
    var mobile: String?
    var email: String?
    var notes: String?
    var isMyContact: Bool = false
    
    init() {
        id = UUID().uuidString
    }
    
    init(_ apiModel: ContactAPI) {
        self.id = apiModel.id
        self.firstName = apiModel.firstName
        self.lastName = apiModel.lastName
        self.mobile = apiModel.mobile
        self.email = apiModel.email
        self.notes = apiModel.notes
    }

    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: Contact, rhs: Contact) -> Bool {
        if lhs.firstName == rhs.firstName {
            return lhs.lastName ?? "" < rhs.lastName ?? ""
        } else {
            return lhs.firstName ?? "" < rhs.firstName ?? ""
        }
    }
}

struct ContactAPI: Codable {
    var id: String
    var firstName: String
    var lastName: String
    var mobile: String
    var email: String
    var notes: String
}

var mockContacts: [Contact] = {
    
    var contacts: [Contact] = []
    
    var contact1 = Contact()
    contact1.firstName = "Ahmed"
    contact1.lastName = "Fathi"
    contact1.mobile = "0112345678"
    contact1.email = "ahmedfathi680@gmail.com"
    contacts.append(contact1)
    
    var contact2 = Contact()
    contact2.firstName = "Radwa"
    contact2.lastName = "Ahmed"
    contact2.mobile = "0112233445"
    contacts.append(contact2)
    
    return contacts
    
}()

// we can also do the above by putting the same code in static func in a class insead of computed property.

