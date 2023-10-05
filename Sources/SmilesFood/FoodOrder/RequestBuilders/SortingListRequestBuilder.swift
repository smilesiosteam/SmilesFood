//
//  SortingListRequestBuilder.swift
//  House
//
//  Created by Hanan Ahmed on 11/8/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import NetworkingLayer
import SmilesOffers

// if you wish you can have multiple services like this in a project
enum SortingListRequestBuilder {
    
    // organise all the end points here for clarity
    case getSortings(request: GetSortingListRequestModel)
    
    // gave a default timeout but can be different for each.
    var requestTimeOut: Int {
        return 20
    }
    
    //specify the type of HTTP request
    var httpMethod: SmilesHTTPMethod {
        switch self {
        case .getSortings:
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
        case .getSortings(let request):
            return request
        }
    }
    
    // compose urls for each request
    func getURL(from environment: Environment? = .UAT, for endPoint: FoodOrderHomeEndPoints) -> String {
        let baseUrl = environment?.serviceBaseUrl
        let endPoint = endPoint.serviceEndPoints
        
        switch self {
        case .getSortings:
            return "\(baseUrl ?? "")\(endPoint)"
        }
    }
}
