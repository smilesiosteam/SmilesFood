//
//  VideoTutorialViewModel.swift
//  House
//
//  Created by Hanan Ahmed on 11/10/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

class VideoTutorialViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getVideoTutorial(operationName: String, sectionKey: String)
    }
    
    enum Output {
        case fetchVideoTutorialDidSucceed(response: GetVideoTutorialResponseModel)
        case fetchVideoTutorialDidFail(error: Error)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension VideoTutorialViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getVideoTutorial(let operationName, let sectionKey):
                self?.getVideoTutorial(for: operationName, sectionKey: sectionKey)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    // Get Video Tutorial
    func getVideoTutorial(for operationName: String, sectionKey: String) {
        
        let getVideoTutorialRequest = GetVideoTutorialRequestModel(
            operationName: operationName,
            sectionKey: sectionKey
        )
        
        let service = GetVideoTutorialRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .videoTutorial
        )
        
        service.getVideoTutorialService(request: getVideoTutorialRequest)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchVideoTutorialDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchVideoTutorialDidSucceed(response: response))
            }
        .store(in: &cancellables)
    }
}

