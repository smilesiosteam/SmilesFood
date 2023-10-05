//
//  GetCuisinesRepository.swift
//  House
//
//  Created by Hanan Ahmed on 10/31/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

protocol CuisinesServiceable {
    func getAllCuisinesService(request: GetCuisinesRequestModel) -> AnyPublisher<GetCuisinesResponseModel, NetworkError>
}

// GetCuisinesRepository
class GetCuisinesRepository: CuisinesServiceable {
    
    private var networkRequest: Requestable
    private var environment: Environment?
    private var endPoint: FoodOrderHomeEndPoints

  // inject this for testability
    init(networkRequest: Requestable, environment: Environment? = .UAT, endPoint: FoodOrderHomeEndPoints) {
        self.networkRequest = networkRequest
        self.environment = environment
        self.endPoint = endPoint
    }
  
    func getAllCuisinesService(request: GetCuisinesRequestModel) -> AnyPublisher<GetCuisinesResponseModel, NetworkError> {
        let endPoint = CuisinesRequestBuilder.getCuisines(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
}
