//
//  RemoveCartRequestModel.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 16/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesBaseMainRequestManager

class RemoveCartRequestModel: SmilesBaseMainRequest {
    // MARK: - Model Variables
    
    var restaurantId: String?
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case restaurantId
    }
    
    init(restaurantId: String? = nil) {
        super.init()
        self.restaurantId = restaurantId
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.restaurantId, forKey: .restaurantId)
    }
}
