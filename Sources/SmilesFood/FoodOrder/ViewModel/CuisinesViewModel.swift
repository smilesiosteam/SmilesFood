//
//  CuisinesViewModel.swift
//  House
//
//  Created by Hanan Ahmed on 10/31/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

class CuisinesViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getCuisines(categoryID: Int, menuItemType: String?)
    }
    
    enum Output {
        case fetchCuisinesDidSucceed(response: GetCuisinesResponseModel)
        case fetchCuisinesDidFail(error: Error)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension CuisinesViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getCuisines(let categoryID, let menuItemType):
                self?.getAllCuisines(for: categoryID, menuItemType: menuItemType)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    // Get All cuisines
    func getAllCuisines(for categoryID: Int, menuItemType: String?) {
        let getCuisinesRequest = GetCuisinesRequestModel(
            categoryId: categoryID,
            menuItemType: menuItemType,
            isGuestUser: isGuestUser
        )
        
        let service = GetCuisinesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .cuisines
        )
        
        service.getAllCuisinesService(request: getCuisinesRequest)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchCuisinesDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchCuisinesDidSucceed(response: response))
            }
        .store(in: &cancellables)
    }
}
