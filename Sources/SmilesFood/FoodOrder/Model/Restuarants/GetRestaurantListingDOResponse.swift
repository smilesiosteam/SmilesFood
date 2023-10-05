//
//  RestaurantListingDOResponse.swift
//  House
//
//  Created by Syed Faraz Haider Zaidi on 03/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesUtilities
import SmilesSharedModels

struct GetRestaurantListingDOResponse: Codable {
    var extTransactionID: String?
    var restaurantBreakSize: Int?
    var isLastPageReached: Bool?
    var defaultSortedName: String?
    var restaurants: [Restaurant]?
    var totalRestaurantCount: Int?
    var isRestaurantBreakEnabled: Bool?
    
    enum CodingKeys: String, CodingKey {
        case extTransactionID = "extTransactionId"
        case restaurantBreakSize, isLastPageReached, defaultSortedName, restaurants, totalRestaurantCount, isRestaurantBreakEnabled
    }
}
