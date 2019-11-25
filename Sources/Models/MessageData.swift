//
//  MessageData.swift
//  lior-sdk
//
//  Created by romaAdmin on 19.11.2019.
//  Copyright © 2019 ItWorksinUA. All rights reserved.
//

import Foundation

// MARK: - MessageData
public struct MessageData: BaseResponse, Codable {
    let pullMessageData: PullMessageData?
    let status: Status?
    
    enum CodingKeys: String, CodingKey {
        case pullMessageData
        case status
    }
}
