//
//  GetOrderHistoryRepository.swift
//  House
//
//  Created by Faraz Haider on 10/31/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

protocol GetOrderHistoryServiceable {
    func getOrderHistoryService(request: GetOrderHistoryDORequest) -> AnyPublisher<GetOrderHistoryDOResponse, NetworkError>
}

class GetOrderHistoryRepository: GetOrderHistoryServiceable {
    
    private var networkRequest: Requestable
    private var environment: Environment?
    private var endPoint: FoodOrderHomeEndPoints

  // inject this for testability
    init(networkRequest: Requestable, environment: Environment? = .UAT, endPoint: FoodOrderHomeEndPoints) {
        self.networkRequest = networkRequest
        self.environment = environment
        self.endPoint = endPoint
    }
  
    func getOrderHistoryService(request: GetOrderHistoryDORequest) -> AnyPublisher<GetOrderHistoryDOResponse, NetworkError> {
        let endPoint = OrderHistoryRequestBuilder.getOrderHistory(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
}
