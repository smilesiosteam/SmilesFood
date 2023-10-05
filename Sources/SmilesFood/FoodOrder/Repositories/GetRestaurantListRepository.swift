//
//  GetRestaurantListRepository.swift
//  House
//
//  Created by Syed Faraz Haider Zaidi on 03/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

protocol GetRestaurantListServiceable {
    func getRestaurantListService(request: GetRestaurantListingDORequest) -> AnyPublisher<GetRestaurantListingDOResponse, NetworkError>
}

class GetRestaurantListRepository: GetRestaurantListServiceable {
    
    private var networkRequest: Requestable
    private var environment: Environment?
    private var endPoint: FoodOrderHomeEndPoints

  // inject this for testability
    init(networkRequest: Requestable, environment: Environment? = .UAT, endPoint: FoodOrderHomeEndPoints) {
        self.networkRequest = networkRequest
        self.environment = environment
        self.endPoint = endPoint
    }
  
    func getRestaurantListService(request: GetRestaurantListingDORequest) -> AnyPublisher<GetRestaurantListingDOResponse, NetworkError> {
        let endPoint = RestaurantListingRequestBuilder.getRestaurantsList(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
}
