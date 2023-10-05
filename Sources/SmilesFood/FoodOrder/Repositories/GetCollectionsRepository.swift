//
//  GetCollectionsRepository.swift
//  House
//
//  Created by Shahroze Zaheer on 10/31/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

protocol CollectionsServiceable {
    func getCollectionsService(request: GetCollectionsRequestModel) -> AnyPublisher<GetCollectionsResponseModel, NetworkError>
}

// GetCollectionsRepository
class GetCollectionsRepository: CollectionsServiceable {
    private var networkRequest: Requestable
    private var environment: Environment?
    private var endPoint: FoodOrderHomeEndPoints

  // inject this for testability
    init(networkRequest: Requestable, environment: Environment? = .UAT, endPoint: FoodOrderHomeEndPoints) {
        self.networkRequest = networkRequest
        self.environment = environment
        self.endPoint = endPoint
    }
  
    func getCollectionsService(request: GetCollectionsRequestModel) -> AnyPublisher<GetCollectionsResponseModel, NetworkingLayer.NetworkError> {
        let endPoint = CollectionsRequestBuilder.getCollections(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
}
