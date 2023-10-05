//
//  TrackOrderOnMapRevampResponseModel.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 15/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation

struct TrackOrderOnMapRevampResponseModel: Codable {
    
    // MARK: - Model Variables
    
    var orderDetails: OrderDetail?
    var orderItems: [OrderItem]?
    var orderItemDetails : [OrderItem]?
    var orderRating: [OrderRatings]?
    var orderTrackingDetails : [TrackOrderOnMapResponseModelOrderTrackingDetail]?
    var orderTimeOut : Int?
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case orderDetails
        case orderItems
        case orderItemDetails
        case orderTrackingDetails = "orderTrackingDetails"
        case orderRating = "orderRatings"
        case orderTimeOut
    }
}
