//
//  GetPopularRestaurantsRepository.swift
//  House
//
//  Created by Hanan Ahmed on 11/3/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

protocol PopularRestaurantsServiceable {
    func getAllPopularRestaurantsService(request: GetPopularRestaurantsRequestModel) -> AnyPublisher<GetPopularRestaurantsResponseModel, NetworkError>
}

// GetPopularRestaurants
class GetPopularRestaurantsRepository: PopularRestaurantsServiceable {
    
    private var networkRequest: Requestable
    private var environment: Environment?
    private var endPoint: FoodOrderHomeEndPoints

  // inject this for testability
    init(networkRequest: Requestable, environment: Environment? = .UAT, endPoint: FoodOrderHomeEndPoints) {
        self.networkRequest = networkRequest
        self.environment = environment
        self.endPoint = endPoint
    }
  
    func getAllPopularRestaurantsService(request: GetPopularRestaurantsRequestModel) -> AnyPublisher<GetPopularRestaurantsResponseModel, NetworkError> {
        let endPoint = PopularRestaurantsRequestBuilder.getPopularRestaurants(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
}
