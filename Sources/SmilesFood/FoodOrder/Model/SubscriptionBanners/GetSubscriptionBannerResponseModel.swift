//
//  GetSubscriptionBannerResponseModel.swift
//  House
//
//  Created by Hanan Ahmed on 11/3/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation

struct GetSubscriptionBannerResponseModel: Codable {
            
    let isFoodSubscription: Bool?
    let subscriptionBanner: SubscriptionsBanner?
    
    enum CodingKeys: String, CodingKey {
        case isFoodSubscription
        case subscriptionBanner
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isFoodSubscription = try values.decodeIfPresent(Bool.self, forKey: .isFoodSubscription)
        subscriptionBanner = try values.decodeIfPresent(SubscriptionsBanner.self, forKey: .subscriptionBanner)
    }
}
