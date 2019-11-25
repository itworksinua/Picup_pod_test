//
//  Status.swift
//  lior-sdk
//
//  Created by romaAdmin on 19.11.2019.
//  Copyright © 2019 ItWorksinUA. All rights reserved.
//

import Foundation

// MARK: - Status
public struct Status: Codable {
    public let msg: String?
    public let code: String?
    
    enum CodingKeys: String, CodingKey {
        case msg
        case code
    }
}

protocol BaseResponse {
    var status: Status? { get }
}

public struct GenericStatus: BaseResponse, Codable {
    public let status: Status?
    
    enum CodingKeys: String, CodingKey {
        case status
    }
}
