//
//  GetSortingListRepository.swift
//  House
//
//  Created by Hanan Ahmed on 11/8/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesOffers

protocol SortingListServiceable {
    func getSortingListService(request: GetSortingListRequestModel) -> AnyPublisher<GetSortingListResponseModel, NetworkError>
}

// GetSortingListRepository
class GetSortingListRepository: SortingListServiceable {
    private var networkRequest: Requestable
    private var environment: Environment?
    private var endPoint: FoodOrderHomeEndPoints

  // inject this for testability
    init(networkRequest: Requestable, environment: Environment? = .UAT, endPoint: FoodOrderHomeEndPoints) {
        self.networkRequest = networkRequest
        self.environment = environment
        self.endPoint = endPoint
    }
  
    func getSortingListService(request: GetSortingListRequestModel) -> AnyPublisher<GetSortingListResponseModel, NetworkingLayer.NetworkError> {
        let endPoint = SortingListRequestBuilder.getSortings(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
    
}
