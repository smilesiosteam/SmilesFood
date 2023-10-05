//
//  OrderRatingRevampRequestModel.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 16/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesBaseMainRequestManager

class OrderRatingRevampRequestModel: SmilesBaseMainRequest {
    
    // MARK: - Model Variables
    
    var ratingType: String?
    var contentType: String?
    var isLiveTracking: Bool?
    var orderId: String?

    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case ratingType
        case contentType
        case isLiveTracking
        case orderId
    }
    
    // MARK: - Model Initializer
    
    init(
        ratingType: String?,
        contentType: String?,
        isLiveTracking: Bool?,
        orderId: String?
    ) {
        super.init()
        self.ratingType = ratingType
        self.contentType = contentType
        self.isLiveTracking = isLiveTracking
        self.orderId = orderId
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.ratingType, forKey: .ratingType)
        try container.encodeIfPresent(self.contentType, forKey: .contentType)
        try container.encodeIfPresent(self.isLiveTracking, forKey: .isLiveTracking)
        try container.encodeIfPresent(self.orderId, forKey: .orderId)
    }
}
