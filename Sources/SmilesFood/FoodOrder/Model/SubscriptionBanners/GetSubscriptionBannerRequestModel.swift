//
//  GetSubscriptionBannerRequestModel.swift
//  House
//
//  Created by Hanan Ahmed on 11/3/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesBaseMainRequestManager

class GetSubscriptionBannerRequestModel: SmilesBaseMainRequest {
    
    // MARK: - Model Variables
    var menuItemType: String?
    var isGuestUser: Bool?

    init(menuItemType: String?, isGuestUser: Bool?) {
        super.init()
        self.menuItemType = menuItemType
        self.isGuestUser = isGuestUser
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    
    enum CodingKeys: CodingKey {
        case menuItemType
        case isGuestUser
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.menuItemType, forKey: .menuItemType)
        try container.encodeIfPresent(self.isGuestUser, forKey: .isGuestUser)
    }
}
