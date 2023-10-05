//
//  AbandonedCartRequestBuilder.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 15/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import NetworkingLayer

enum AbandonedCartRequestBuilder {
    
    case getAbandonedCart(request: RegisterLocationRequestModel)
    case getOrderStatus(request: ConfirmOrderRequestModel)
    case setOrderStatus(request: ConfirmOrderRequestModel)
    case removeCart(request: RemoveCartRequestModel)
    case getLiveChatUrl(request: FoodOrderChatRevampRequestModel)
    case getOrderRating(request: OrderRatingRevampRequestModel)
    
    // gave a default timeout but can be different for each.
    var requestTimeOut: Int {
        return 20
    }
    
    //specify the type of HTTP request
    var httpMethod: SmilesHTTPMethod {
        switch self {
        case .getAbandonedCart:
            return .POST
        case .getOrderStatus:
            return .POST
        case .setOrderStatus:
            return .POST
        case .removeCart:
            return .POST
        case .getLiveChatUrl:
            return .POST
        case .getOrderRating:
            return .POST
        }
    }
    
    // compose the NetworkRequest
    func createRequest(environment: Environment? = .UAT, endPoint: FoodOrderHomeEndPoints) -> NetworkRequest {
        var headers: Headers = [:]

        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        headers["CUSTOM_HEADER"] = "pre_prod"
        
        return NetworkRequest(url: getURL(from: environment, for: endPoint), headers: headers, reqBody: requestBody, httpMethod: httpMethod)
    }
    
    // encodable request body for POST
    var requestBody: Encodable? {
        switch self {
        case .getAbandonedCart(let request):
            return request
        case .getOrderStatus(let request):
            return request
        case .setOrderStatus(let request):
            return request
        case .removeCart(let request):
            return request
        case .getLiveChatUrl(let request):
            return request
        case .getOrderRating(let request):
            return request
        }
    }
    
    // compose urls for each request
    func getURL(from environment: Environment? = .UAT, for endPoint: FoodOrderHomeEndPoints) -> String {
        let baseUrl = environment?.serviceBaseUrl
        let endPoint = endPoint.serviceEndPoints
        
        switch self {
        case .getAbandonedCart:
            return "\(baseUrl ?? "")\(endPoint)"
        case .getOrderStatus:
            return "\(baseUrl ?? "")\(endPoint)"
        case .setOrderStatus:
            return "\(baseUrl ?? "")\(endPoint)"
        case .removeCart:
            return "\(baseUrl ?? "")\(endPoint)"
        case .getLiveChatUrl:
            return "\(baseUrl ?? "")\(endPoint)"
        case .getOrderRating:
            return "\(baseUrl ?? "")\(endPoint)"
        }
    }
}
