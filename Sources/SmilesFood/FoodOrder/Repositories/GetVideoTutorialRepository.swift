//
//  GetVideoTutorialRepository.swift
//  House
//
//  Created by Hanan Ahmed on 11/10/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

protocol VideoTutorialServiceable {
    func getVideoTutorialService(request: GetVideoTutorialRequestModel) -> AnyPublisher<GetVideoTutorialResponseModel, NetworkError>
}

// GetVideoTutorialRepository
class GetVideoTutorialRepository: VideoTutorialServiceable {
    private var networkRequest: Requestable
    private var environment: Environment?
    private var endPoint: FoodOrderHomeEndPoints

  // inject this for testability
    init(networkRequest: Requestable, environment: Environment? = .UAT, endPoint: FoodOrderHomeEndPoints) {
        self.networkRequest = networkRequest
        self.environment = environment
        self.endPoint = endPoint
    }
  
    func getVideoTutorialService(request: GetVideoTutorialRequestModel) -> AnyPublisher<GetVideoTutorialResponseModel, NetworkingLayer.NetworkError> {
        let endPoint = VideoTutorialRequestBuilder.getVideoTutorial(request: request)
        let request = endPoint.createRequest(
            environment: self.environment,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
    
}
