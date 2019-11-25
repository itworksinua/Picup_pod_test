//
//  SDKService.swift
//  PICUP_SDK
//
//  Created by Admin on 19.11.2019.
//  Copyright © 2019 ItWorksinUA. All rights reserved.
//

import Foundation
import AddressBook
import Contacts
import UIKit

// MARK: - PullMessageData
public struct PCUSDKUser {
    var phoneNumber: String
    var name: String
    var token: String
    var appVersion = "4.3.7.2 ( 248780747 )"
    var sdkVersion = "2.6.6"
    var deviceName = "samsung"
    var deviceModel = "SM-G973F"
    var osVersion = ""
    var screenSize = "2042x1080"
    var screenDensity = "420"
    var mode = "Waked ( On App )"
    var permission = "1,1,0,1,1"
    var serviceEnabled = "true"
}

open class SDKService {
    
    public static let shared = SDKService()
    
    func getData(_ user: PCUSDKUser, finalBlock: @escaping ()->() ){
        NetworkService.shared.deviceToken = user.token
        NetworkService.shared.getSessionToken { (err) in
            NetworkService.shared.registerClientDevice(phoneNumber: user.phoneNumber, name: user.name) { (dev, err) in
                NetworkService.shared.pullMessageData(status: "App. version: \(user.appVersion) \nSDK version: \(user.sdkVersion) \nDevice name: \(user.deviceName) \nDevice model: \(user.deviceModel) \nOS version: \(user.osVersion) \nScreen size: \(user.screenSize) \nScreen density: \(user.screenDensity) \nMode: \(user.mode) \nPermissions: \(user.permission) \nService enabled: \(user.serviceEnabled)") { (data, err) in
                    let worker = CNWorker.init(nil)
                    worker.requestForAccess { (success) in
                        if let group = worker.makeGroup() {
                            if let persons = data?.pullMessageData?.campaignsData {
                                for person in persons {
                                    let newContact = CNMutableContact()
                                    newContact.givenName = person.name ?? ""
                                    newContact.organizationName = person.dispText ?? ""
                                    newContact.departmentName = person.dispName ?? ""
                                    let urlStr = "https://picup-server-sdk-v2.appspot.com" + "\(person.imageURL!)"
                                    if let url = URL(string: urlStr), let imgData = try? Data(contentsOf: url) {
                                        if let image = UIImage(data: imgData) {
                                            newContact.imageData = image.pngData()
                                        }
                                    }
                                    //newContact.note = "PICUP SDK"
                                    newContact.phoneNumbers = [CNLabeledValue(
                                        label:CNLabelPhoneNumberiPhone,
                                        value:CNPhoneNumber(stringValue:person.backNumber!))]
                                    do {
                                        let saveRequest = CNSaveRequest()
                                        saveRequest.add(newContact, toContainerWithIdentifier: worker.curContainer?.identifier)
                                        saveRequest.addMember(newContact, to: group)
                                        try worker.contactStore.execute(saveRequest)
                                    } catch {
                                    }
                                    finalBlock()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}
