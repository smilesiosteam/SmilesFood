//
//  SubscriptionBannerViewModel.swift
//  House
//
//  Created by Hanan Ahmed on 11/3/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

class SubscriptionBannerViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getSubscriptionBanner(menuItemType: String?)
    }
    
    enum Output {
        case fetchSubscriptionBannerDidSucceed(response: GetSubscriptionBannerResponseModel)
        case fetchSubscriptionBannerDidFail(error: Error)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension SubscriptionBannerViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getSubscriptionBanner(let menuItemType):
                self?.getSubscriptionBanner(for: menuItemType)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    // Get Subscription Banner
    func getSubscriptionBanner(for menuItemType: String?) {
        let getSubscriptionBannerRequest = GetSubscriptionBannerRequestModel(
            menuItemType: menuItemType,
            isGuestUser: isGuestUser
        )
        
        let service = GetSubscriptionBannerRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .subscriptionBanner
        )
        
        service.getSubscriptionBannerService(request: getSubscriptionBannerRequest)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchSubscriptionBannerDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchSubscriptionBannerDidSucceed(response: response))
            }
        .store(in: &cancellables)
    }
}
