//
//  TopAdsViewModel.swift
//  House
//
//  Created by Muhammad Shayan Zahid on 18/01/2023.
//  Copyright © 2023 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesBanners

class TopAdsViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getTopAds(menuItemType: RestaurantMenuType?)
    }
    
    enum Output {
        case getTopAdsDidSucceed(response: GetTopAdsResponseModel)
        case getTopAdsDidFail(error: Error)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - INPUT. View event methods
extension TopAdsViewModel {
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getTopAds(let menuItemType):
                self?.getTopAds(menuItemType: menuItemType)
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    
    func getTopAds(menuItemType: RestaurantMenuType?) {
        let getTopAdsRequestModel = GetTopAdsRequestModel(bannerType: nil, menuItemType: menuItemType?.rawValue, isGuestUser: isGuestUser)
        
        let service = GetTopAdsRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: menuItemType == nil ? .topAds : .topAdsWithType
        )
        
        service.getTopAdsService(request: getTopAdsRequestModel)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.getTopAdsDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.getTopAdsDidSucceed(response: response))
            }
        .store(in: &cancellables)
    }
}
