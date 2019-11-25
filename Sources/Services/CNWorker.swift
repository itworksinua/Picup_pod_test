//
//  CNWorker.swift
//  Phonebridge
//
//  Created by Admin on 6/18/19.
//  Copyright © 2019 ItWorksinUA. All rights reserved.
//

import UIKit
import AddressBook
import Contacts

class CNWorker: NSObject {
    let contactStore = CNContactStore()
    var viewController: UIViewController?
    var curContainer: CNContainer?
    
    init(_ viewController: UIViewController!) {
        self.viewController = viewController
    }
    
    //mark: address book
    func requestForAccess(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == CNAuthorizationStatus.denied {
//                        self.showMessage("Error", message: "App will not work without authorization permission")
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    func checkDefaultContainer(){
        let ident = self.contactStore.defaultContainerIdentifier()
        let predicate = CNContainer.predicateForContainers(withIdentifiers: [ident])
        if let foundContainers = try? self.contactStore.containers(matching: predicate) {
            if let container = foundContainers[0] as? CNContainer {
                if container.type != .exchange {
                    curContainer = container
                }
            }
        }
    }
    
    func selectDefaultContainer() {
        if let foundContainers = try? self.contactStore.containers(matching: nil) {
            if let container = foundContainers[0] as? CNContainer {
                if container.type == .cardDAV {
                    curContainer = container
                }
            }
        }
    }
    
    func makeGroup() -> CNGroup? {
        self.checkDefaultContainer()
        if curContainer == nil {
            self.selectDefaultContainer()
        }
        if let foundGroups = try? self.contactStore.groups(matching: nil) {
            for group in foundGroups {
                if group.name.lowercased() == "PICUP SDK".lowercased() {
                    self.clearContactsInGroup(group: group)
                    do {
                        let saveRequest = CNSaveRequest()
                        saveRequest.delete(group.mutableCopy() as! CNMutableGroup)
                        try self.contactStore.execute(saveRequest)
                    } catch let err {
                    }
                }
            }
        }
        let group = CNMutableGroup()
        group.name = "PICUP SDK"
        do {
            let saveRequest = CNSaveRequest()
            saveRequest.add(group, toContainerWithIdentifier: curContainer?.identifier)
            try self.contactStore.execute(saveRequest)
            return group
        } catch let err {
//            self.showMessage("Error", message: "Can't create LDAP group \(err)")
            return nil
        }
    }
    
    func clearContactsInGroup(group: CNGroup) {
        let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)
        if let foundContacts = try? self.contactStore.unifiedContacts(matching: predicate, keysToFetch: []) {
            for contact in foundContacts {
                do {
                    let saveRequest = CNSaveRequest()
                    saveRequest.delete(contact.mutableCopy() as! CNMutableContact)
                    try self.contactStore.execute(saveRequest)
                } catch let err {
                    print("Error", err)
//                    self.showMessage("Error", message: "Can't clear group")
                }
            }
        }
    }
    
    func clearAll() {
        if let foundGroups = try? self.contactStore.groups(matching: nil) {
            for group in foundGroups {
                if group.name.lowercased() == "PICUP SDK".lowercased() {
                    self.clearContactsInGroup(group: group)
                    do {
                        let saveRequest = CNSaveRequest()
                        saveRequest.delete(group.mutableCopy() as! CNMutableGroup)
                        try self.contactStore.execute(saveRequest)
                    } catch let err {
                    }
                }
            }
        }
    }
    
}
