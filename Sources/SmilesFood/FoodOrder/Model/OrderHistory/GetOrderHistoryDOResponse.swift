//
//  OrderHistoryDOResponse.swift
//  House
//
//  Created by Syed Faraz Haider Zaidi on 03/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation

// MARK: - OrderHistoryDOResponse
struct GetOrderHistoryDOResponse: Codable {
    let extTransactionID: String?
    let isLastPageReached: Bool?
    let activeOrders, inActiveOrders: [OrderListDO]?

    enum CodingKeys: String, CodingKey {
        case extTransactionID = "extTransactionId"
        case isLastPageReached, activeOrders, inActiveOrders
    }
}

// MARK: - ActiveOrder
struct OrderListDO: Codable {
    let orderID, orderNumber, restaurentName, date: String?
    let totalPrice, orderDescription: String?
    let orderStatus, earnPoints: Int?
    let refunds, reOrder, isCurrentOrder: Bool?
    let items: [ItemDO]?
    let restaurantID: String?
    let virtualRestaurantIncluded: Bool?
    let cuisines: [String]?
    let restaurantRating: Double?
    let restaurantDistance: Int?
    let deliveryTime: Int?
    let orderType: String?
    let imageUrl, iconUrl, imageUrlLarge: String?

    enum CodingKeys: String, CodingKey {
        case orderID = "orderId"
        case orderNumber, restaurentName, date, totalPrice, orderDescription, orderStatus, earnPoints, refunds, reOrder, isCurrentOrder, items
        case restaurantID = "restaurantId"
        case virtualRestaurantIncluded, cuisines, restaurantRating, restaurantDistance, deliveryTime, orderType, imageUrl, iconUrl, imageUrlLarge
    }
}

// MARK: - Item
struct ItemDO: Codable {
    let itemName: String?
    let quantity: Int?
}

