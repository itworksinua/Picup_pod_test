//
//  sessionToken.swift
//  lior-sdk
//
//  Created by romaAdmin on 19.11.2019.
//  Copyright © 2019 ItWorksinUA. All rights reserved.
//

import Foundation

// MARK: - SessionToken
public struct SessionToken: BaseResponse, Codable {
    let status: Status?
    let token: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case token
    }
    
    init(status: Status?, token: String?) {
        self.status = status
        self.token = token
    }
}
