//
//  CollectionsViewModel.swift
//  House
//
//  Created by Shahroze Zaheer on 10/31/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

class CollectionsViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getCollections(categoryID: Int, menuItemType: String?)
    }
    
    enum Output {
        case fetchCollectionsDidSucceed(response: GetCollectionsResponseModel)
        case fetchCollectionsDidFail(error: Error)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension CollectionsViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getCollections(let categoryID, let menuItemType):
                self?.getCollections(for: categoryID, menuItemType: menuItemType)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    // Get All cuisines
    func getCollections(for categoryID: Int, menuItemType: String?) {
        let getCuisinesRequest = GetCollectionsRequestModel(
            categoryId: categoryID,
            menuItemType: menuItemType,
            isGuestUser: isGuestUser
        )
        
        let service = GetCollectionsRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .collections
        )
        
        service.getCollectionsService(request: getCuisinesRequest)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchCollectionsDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchCollectionsDidSucceed(response: response))
            }
        .store(in: &cancellables)
    }
}
