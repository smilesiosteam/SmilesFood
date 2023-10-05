//
//  ReOrderFoodRespository.swift
//  House
//
//  Created by Hanan Ahmed on 7/18/23.
//  Copyright © 2023 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

protocol ReOrderFoodServiceable {
    func reOrderFoodService(request: ReOrderFoodRequestModel) -> AnyPublisher<ReOrderResponseModel, NetworkError>
}

class ReOrderFoodRespository: ReOrderFoodServiceable {
    
    private var networkRequest: Requestable
    private var environment: Environment?
    private var endPoint: FoodOrderHomeEndPoints

  // inject this for testability
    init(networkRequest: Requestable, environment: Environment? = .UAT, endPoint: FoodOrderHomeEndPoints) {
        self.networkRequest = networkRequest
        self.environment = environment
        self.endPoint = endPoint
    }
  
    func reOrderFoodService(request: ReOrderFoodRequestModel) -> AnyPublisher<ReOrderResponseModel, NetworkError> {
        let endPoint = ReOrderFoodRequestBuilder.reOrderFood(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
}
