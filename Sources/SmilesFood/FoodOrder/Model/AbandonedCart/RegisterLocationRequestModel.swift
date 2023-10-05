//
//  RegisterLocationRequestModel.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 15/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesBaseMainRequestManager
import SmilesUtilities
import SmilesSharedModels

class RegisterLocationRequestModel: SmilesBaseMainRequest {
    
    // MARK: - Model Variables
    
    var filters: [RestaurantRequestFilter]?
    var menuItemType: String?
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case filters
        case menuItemType
    }
    
    init(filters: [RestaurantRequestFilter]? = [], menuItemType: String? = nil) {
        super.init()
        self.filters = filters
        self.menuItemType = menuItemType
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.filters, forKey: .filters)
        try container.encodeIfPresent(self.menuItemType, forKey: .menuItemType)
    }
}
