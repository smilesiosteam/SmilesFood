//
//  OrderHistoryDORequest.swift
//  House
//
//  Created by Syed Faraz Haider Zaidi on 03/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesBaseMainRequestManager
import SmilesOffers

class GetOrderHistoryDORequest: SmilesBaseMainRequest {
    
    // MARK: - Model Variables
    
    var filters : [FilterDO]?
    var pageNo : Int?
    var orderType: RestaurantMenuType?

    
    init(filters: [FilterDO]?, pageNo: Int?, orderType: RestaurantMenuType?) {
        super.init()
        self.filters = filters
        self.pageNo = pageNo
        self.orderType = orderType
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    
    enum CodingKeys: String, CodingKey {
        case filters
        case pageNo
        case orderType = "menuItemType"
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.filters, forKey: .filters)
        try container.encodeIfPresent(self.pageNo, forKey: .pageNo)
        try container.encodeIfPresent(self.orderType, forKey: .orderType)
    }
}
