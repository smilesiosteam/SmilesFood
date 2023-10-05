//
//  RestaurantListingDORequest.swift
//  House
//
//  Created by Syed Faraz Haider Zaidi on 03/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesBaseMainRequestManager
import SmilesUtilities
import SmilesSharedModels

class GetRestaurantListingDORequest: SmilesBaseMainRequest {

    var filters : [RestaurantRequestFilter]?
    var pageNo : Int?
    var menuItemType: String?
    var operationName : String?
    var isGuestUser: Bool?
    
    enum CodingKeys: String, CodingKey {
        case pageNo
        case menuItemType
        case filters
        case operationName
        case isGuestUser
    }
    
    init(filters: [RestaurantRequestFilter]? = nil, pageNo: Int? = nil, menuItemType: String? = nil, operationName: String? = nil, isGuestUser: Bool?) {
        super.init()
        self.filters = filters
        self.pageNo = pageNo
        self.menuItemType = menuItemType
        self.operationName = operationName
        self.isGuestUser = isGuestUser
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.filters, forKey: .filters)
        try container.encodeIfPresent(self.pageNo, forKey: .pageNo)
        try container.encodeIfPresent(self.menuItemType, forKey: .menuItemType)
        try container.encodeIfPresent(self.operationName, forKey: .operationName)
        try container.encodeIfPresent(self.isGuestUser, forKey: .isGuestUser)
    }
    
}
