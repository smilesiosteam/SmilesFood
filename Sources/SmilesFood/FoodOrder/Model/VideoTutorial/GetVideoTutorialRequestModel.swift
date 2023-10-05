//
//  GetVideoTutorialRequestModel.swift
//  House
//
//  Created by Hanan Ahmed on 11/10/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesBaseMainRequestManager

class GetVideoTutorialRequestModel: SmilesBaseMainRequest {
    
    // MARK: - Model Variables
    var operationName: String?
    var sectionKey: String?
    
    init(operationName: String?, sectionKey: String?) {
        super.init()
        self.operationName = operationName
        self.sectionKey = sectionKey
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    
    enum CodingKeys: CodingKey {
        case operationName
        case sectionKey
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.operationName, forKey: .operationName)
        try container.encodeIfPresent(self.sectionKey, forKey: .sectionKey)
    }
}
