//
//  GetPopularRestaurantsRequestModel.swift
//  House
//
//  Created by Hanan Ahmed on 11/3/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesBaseMainRequestManager

enum PopularRestaurantRequest: String {
    case recommended
    case popup
}

class GetPopularRestaurantsRequestModel: SmilesBaseMainRequest {
    
    // MARK: - Model Variables
    
    var menuItemType: String?
    var isGuestUser: Bool?
    var type: String?
    
    init(menuItemType: String?, isGuestUser: Bool?, type: PopularRestaurantRequest) {
        super.init()
        self.menuItemType = menuItemType
        self.isGuestUser = isGuestUser
        self.type = type.rawValue
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    
    enum CodingKeys: CodingKey {
        case menuItemType
        case isGuestUser
        case type
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.menuItemType, forKey: .menuItemType)
        try container.encodeIfPresent(self.isGuestUser, forKey: .isGuestUser)
        try container.encodeIfPresent(self.type, forKey: .type)
    }
}
