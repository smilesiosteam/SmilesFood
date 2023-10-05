//
//  ConfirmOrderRequestModel.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 15/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesBaseMainRequestManager

class ConfirmOrderRequestModel: SmilesBaseMainRequest {
    
    // MARK: - Model Variables
    
    var orderId: String?
    var orderStatus: Int?
    var isChangeType: Bool?
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case orderId
        case orderStatus
        case isChangeType
    }
    
    // MARK: - Initializer
    
    init(orderId: String? = "", orderStatus: Int? = nil, isChangeType: Bool? = nil) {
        super.init()
        self.orderId = orderId
        self.orderStatus = orderStatus
        self.isChangeType = isChangeType
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Methods
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.orderId, forKey: .orderId)
        try container.encodeIfPresent(self.orderStatus, forKey: .orderStatus)
        try container.encodeIfPresent(self.isChangeType, forKey: .isChangeType)
    }
}
