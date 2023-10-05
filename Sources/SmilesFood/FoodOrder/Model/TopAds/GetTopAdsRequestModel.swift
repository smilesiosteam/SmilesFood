//
//  GetTopAdsRequestModel.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 18/01/2023.
//  Copyright © 2023 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesBaseMainRequestManager

class GetTopAdsRequestModel: SmilesBaseMainRequest {
    
    // MARK: - Model Variables
    
    var bannerType: String?
    var menuItemType: String?
    var isGuestUser: Bool?
    
    init(bannerType: String?, menuItemType: String?, isGuestUser: Bool?) {
        super.init()
        self.bannerType = bannerType
        self.menuItemType = menuItemType
        self.isGuestUser = isGuestUser
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    
    enum CodingKeys: CodingKey {
        case bannerType
        case menuItemType
        case isGuestUser
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.bannerType, forKey: .bannerType)
        try container.encodeIfPresent(self.menuItemType, forKey: .menuItemType)
        try container.encodeIfPresent(self.isGuestUser, forKey: .isGuestUser)
    }
}
