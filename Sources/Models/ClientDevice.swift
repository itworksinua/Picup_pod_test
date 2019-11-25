//
//  ClientDevice.swift
//  lior-sdk
//
//  Created by romaAdmin on 19.11.2019.
//  Copyright © 2019 ItWorksinUA. All rights reserved.
//

import Foundation

// MARK: - ClientDevice
public struct ClientDevice: BaseResponse, Codable {
    let status: Status?
    let organizationPhoneNumber: String?
    let pullMessageData: PullMessageData?
    let organizationDisplayName: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case organizationPhoneNumber
        case pullMessageData
        case organizationDisplayName
    }
}

// MARK: - PullMessageData
public struct PullMessageData: Codable {
    let organizationData: OrganizationData?
    let campaignsData: [CampaignsDatum]?
    let senderID: String?
    let campaignID: Int?
    let senderGUID: String?
    let messageType: String?
    let outgoingNumbersData: [OutgoingNumbersDatum]?
    
    enum CodingKeys: String, CodingKey {
        case organizationData
        case campaignsData
        case senderID
        case campaignID
        case senderGUID
        case messageType
        case outgoingNumbersData
    }
}

// MARK: - CampaignsDatum
public struct CampaignsDatum: Codable {
    let campID: Int?
    let dispName: String?
    let id: Int?
    let backNumber: String?
    let msgFormat: String?
    let expireTime: String?
    let dispText: String?
    let imageURL: String?
    let imageDate: Int?
    let name: String?
    let screenConfig: Int?
    
    enum CodingKeys: String, CodingKey {
        case campID
        case dispName
        case id
        case backNumber
        case msgFormat
        case expireTime
        case dispText
        case imageURL
        case imageDate
        case name
        case screenConfig
    }
}

// MARK: - OrganizationData
public struct OrganizationData: Codable {
    let logoDate: Int?
    let logoURL: String?
    let phoneNumber: String?
    let disable: Int?
    let name: String?
    let contact: Int?
    let id: Int?
    let imageDate: Int?
    let dispName: String?
    let dispText: String?
    let imageURL: String?
    let orgCode: Int?
    let color2: String?
    let carrier: Int?
    let color1: String?
    
    enum CodingKeys: String, CodingKey {
        case logoDate
        case logoURL
        case phoneNumber
        case disable
        case name
        case contact
        case id
        case imageDate
        case dispName
        case dispText
        case imageURL
        case orgCode
        case color2
        case carrier
        case color1
    }
}

// MARK: - OutgoingNumbersDatum
public struct OutgoingNumbersDatum: Codable {
    let number: String?
    let id: Int?
    
    enum CodingKeys: String, CodingKey {
        case number
        case id
    }
}
