//
//  FoodOrderChatRevampRequestModel.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 16/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesBaseMainRequestManager

class FoodOrderChatRevampRequestModel: SmilesBaseMainRequest {
    
    // MARK: - Model Variables
    
    var orderId: String?
    var chatbotType: String?
    var orderNumber: String?
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case orderId
        case orderNumber
        case chatbotType
    }
    
    // MARK: - Model Initializer
    
    init(orderId: String?, chatbotType: String?, orderNumber: String?) {
        super.init()
        self.orderId = orderId
        self.chatbotType = chatbotType
        self.orderNumber = orderNumber
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.orderId, forKey: .orderId)
        try container.encodeIfPresent(self.orderNumber, forKey: .orderNumber)
        try container.encodeIfPresent(self.chatbotType, forKey: .chatbotType)
    }
}
