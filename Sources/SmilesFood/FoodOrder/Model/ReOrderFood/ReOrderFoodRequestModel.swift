//
//  ReOrderFoodRequestModel.swift
//  House
//
//  Created by Hanan Ahmed on 7/19/23.
//  Copyright © 2023 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesBaseMainRequestManager

class ReOrderFoodRequestModel: SmilesBaseMainRequest {
    
    // MARK: - Model Variables
    
    var orderId: String?

    init(orderId: String?) {
        super.init()
        self.orderId = orderId
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    
    enum CodingKeys: CodingKey {
        case orderId
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.orderId, forKey: .orderId)
    }
    
}
