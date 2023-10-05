//
//  GetSubscriptionBannerRepository.swift
//  House
//
//  Created by Hanan Ahmed on 11/3/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

protocol SubscriptionBannerServiceable {
    func getSubscriptionBannerService(request: GetSubscriptionBannerRequestModel) -> AnyPublisher<GetSubscriptionBannerResponseModel, NetworkError>
}

// GetSubscriptionBannerRepository
class GetSubscriptionBannerRepository: SubscriptionBannerServiceable {
    private var networkRequest: Requestable
    private var environment: Environment?
    private var endPoint: FoodOrderHomeEndPoints

  // inject this for testability
    init(networkRequest: Requestable, environment: Environment? = .UAT, endPoint: FoodOrderHomeEndPoints) {
        self.networkRequest = networkRequest
        self.environment = environment
        self.endPoint = endPoint
    }
  
    func getSubscriptionBannerService(request: GetSubscriptionBannerRequestModel) -> AnyPublisher<GetSubscriptionBannerResponseModel, NetworkingLayer.NetworkError> {
        let endPoint = SubscriptionBannerRequestBuilder.getSubscriptionBanner(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
    
}
