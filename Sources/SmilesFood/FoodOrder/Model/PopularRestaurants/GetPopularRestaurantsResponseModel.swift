//
//  GetPopularRestaurantsResponseModel.swift
//  House
//
//  Created by Hanan Ahmed on 11/3/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesUtilities
import SmilesSharedModels

struct GetPopularRestaurantsResponseModel: Codable {
    var restaurants: [Restaurant]?
    var isLastPageReached: Bool?
    var sectionName: String?
    var sectionDescription: String?
    var eventName: String?
    
    enum CodingKeys: String, CodingKey {
        case restaurants
        case isLastPageReached
        case sectionName
        case sectionDescription
        case eventName
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        restaurants = try values.decodeIfPresent([Restaurant].self, forKey: .restaurants)
        isLastPageReached = try values.decodeIfPresent(Bool.self, forKey: .isLastPageReached)
        sectionName = try values.decodeIfPresent(String.self, forKey: .sectionName)
        sectionDescription = try values.decodeIfPresent(String.self, forKey: .sectionDescription)
        eventName = try values.decodeIfPresent(String.self, forKey: .eventName)
    }
}
