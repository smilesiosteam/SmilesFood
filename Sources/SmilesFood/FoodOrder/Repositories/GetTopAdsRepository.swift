//
//  GetTopAdsRepository.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 18/01/2023.
//  Copyright © 2023 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesBanners

protocol GetTopAdsServiceable {
    func getTopAdsService(request: GetTopAdsRequestModel) -> AnyPublisher<GetTopAdsResponseModel, NetworkError>
}

class GetTopAdsRepository: GetTopAdsServiceable {
    
    private var networkRequest: Requestable
    private var environment: Environment?
    private var endPoint: FoodOrderHomeEndPoints
    
    init(networkRequest: Requestable, environment: Environment? = .UAT, endPoint: FoodOrderHomeEndPoints) {
        self.networkRequest = networkRequest
        self.environment = environment
        self.endPoint = endPoint
    }
    
    func getTopAdsService(request: GetTopAdsRequestModel) -> AnyPublisher<GetTopAdsResponseModel, NetworkError> {
        let endPoint = TopAdsRequestBuilder.getTopAds(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
}
