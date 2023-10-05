//
//  FoodOrderHomeEndPoints.swift
//  House
//
//  Created by Hanan Ahmed on 10/31/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation

public enum FoodOrderHomeEndPoints: String, CaseIterable {
    case cuisines
    case orderHistory
    case collections
    case topBrands
    case topOffers
    case topOffersWithMenuList
    case storiesList
    case restaurantList
    case popularRestaurants
    case subscriptionBanner
    case sortingList
    case videoTutorial
    case abandonedCart
    case orderStatus
    case removeCart
    case orderConfirmStatus
    case liveChatDetails
    case orderRating
    case topAds
    case topAdsWithType
    case reOrderFood
}

extension FoodOrderHomeEndPoints {
    var serviceEndPoints: String {
        switch self {
        case .cuisines:
            return "home/v1/cuisines"
        case .orderHistory:
            return "order/v1/get-order-history"
        case .collections:
            return "home/v1/collections"
        case .topBrands:
            return "home/v1/top-brands"
        case .topOffers:
            return "home/v3/get-ads"
        case .topOffersWithMenuList:
            return "menu-list/v1/get-ads"
        case .storiesList:
            return "home/v2/stories"
        case .restaurantList:
            return "menu-list/v1/restaurants"
        case .popularRestaurants:
            return "menu-list/v1/popular-restaurants"
        case .subscriptionBanner:
            return "menu-list/v1/subscription-banner"
        case .sortingList:
            return "menu-list/v1/get-sorting"
        case .videoTutorial:
            return "home/v1/get-video-tutorial"
        case .abandonedCart:
            return "cart/v1/get-abandoned-cart"
        case .orderStatus:
            return "order/v1/order-tracking-status"
        case .removeCart:
            return "cart/v1/clear-cart-item"
        case .orderConfirmStatus:
            return "order/v1/order-confirm-status"
        case .liveChatDetails:
            return "chatbot/get-live-chat-details"
        case .orderRating:
            return "order-review/v1/order-rating"
        case .topAds:
            return "home/v1/get-ads"
        case .topAdsWithType:
            return "menu-list/v1/get-ads"
        case .reOrderFood:
            return "order/v1/re-order-food"
        }
    }
}

