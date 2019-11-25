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
    public let status: Status?
    public let organizationPhoneNumber: String?
    public let pullMessageData: PullMessageData?
    public let organizationDisplayName: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case organizationPhoneNumber
        case pullMessageData
        case organizationDisplayName
    }
}

// MARK: - PullMessageData
public struct PullMessageData: Codable {
    public let organizationData: OrganizationData?
    public let campaignsData: [CampaignsDatum]?
    public let senderID: String?
    public let campaignID: Int?
    public let senderGUID: String?
    public let messageType: String?
    public let outgoingNumbersData: [OutgoingNumbersDatum]?
    
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
    public let campID: Int?
    public let dispName: String?
    public let id: Int?
    public let backNumber: String?
    public let msgFormat: String?
    public let expireTime: String?
    public let dispText: String?
    public let imageURL: String?
    public let imageDate: Int?
    public let name: String?
    public let screenConfig: Int?
    
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
    public let logoDate: Int?
    public let logoURL: String?
    public let phoneNumber: String?
    public let disable: Int?
    public let name: String?
    public let contact: Int?
    public let id: Int?
    public let imageDate: Int?
    public let dispName: String?
    public let dispText: String?
    public let imageURL: String?
    public let orgCode: Int?
    public let color2: String?
    public let carrier: Int?
    public let color1: String?
    
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
    public let number: String?
    public let id: Int?
    
    enum CodingKeys: String, CodingKey {
        case number
        case id
    }
}
