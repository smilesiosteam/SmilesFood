//
//  GetAbandonedCartRepository.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 15/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

protocol GetAbandonedCartServiceable {
    func getAbandonedCartService(request: RegisterLocationRequestModel) -> AnyPublisher<AbandonedListResponseModel, NetworkError>
    func getOrderStatusService(request: ConfirmOrderRequestModel) -> AnyPublisher<TrackOrderOnMapRevampResponseModel, NetworkError>
    func setOrderStatusService(request: ConfirmOrderRequestModel) -> AnyPublisher<BaseMainResponse, NetworkError>
    func removeCartService(request: RemoveCartRequestModel) -> AnyPublisher<BaseMainResponse, NetworkError>
    func getLiveChatUrlService(request: FoodOrderChatRevampRequestModel) -> AnyPublisher<FoodOrderChatRevampResponseModel, NetworkError>
    func getOrderRatingService(request: OrderRatingRevampRequestModel) -> AnyPublisher<OrderRatingResponse, NetworkError>
}

class GetAbandonedCartRepository: GetAbandonedCartServiceable {
    
    private var networkRequest: Requestable
    private var environment: Environment?
    private var endPoint: FoodOrderHomeEndPoints
    
    init(networkRequest: Requestable, environment: Environment? = .UAT, endPoint: FoodOrderHomeEndPoints) {
        self.networkRequest = networkRequest
        self.environment = environment
        self.endPoint = endPoint
    }
    
    func getAbandonedCartService(request: RegisterLocationRequestModel) -> AnyPublisher<AbandonedListResponseModel, NetworkError> {
        let endPoint = AbandonedCartRequestBuilder.getAbandonedCart(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
    
    func getOrderStatusService(request: ConfirmOrderRequestModel) -> AnyPublisher<TrackOrderOnMapRevampResponseModel, NetworkError> {
        let endPoint = AbandonedCartRequestBuilder.getOrderStatus(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
    
    func setOrderStatusService(request: ConfirmOrderRequestModel) -> AnyPublisher<BaseMainResponse, NetworkError> {
        let endPoint = AbandonedCartRequestBuilder.setOrderStatus(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
    
    func removeCartService(request: RemoveCartRequestModel) -> AnyPublisher<BaseMainResponse, NetworkError> {
        let endPoint = AbandonedCartRequestBuilder.removeCart(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
    
    func getLiveChatUrlService(request: FoodOrderChatRevampRequestModel) -> AnyPublisher<FoodOrderChatRevampResponseModel, NetworkError> {
        let endPoint = AbandonedCartRequestBuilder.getLiveChatUrl(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
    
    func getOrderRatingService(request: OrderRatingRevampRequestModel) -> AnyPublisher<OrderRatingResponse, NetworkError> {
        let endPoint = AbandonedCartRequestBuilder.getOrderRating(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
}
