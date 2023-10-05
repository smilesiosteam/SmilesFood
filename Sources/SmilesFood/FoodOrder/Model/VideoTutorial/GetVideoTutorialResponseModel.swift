//
//  GetVideoTutorialResponseModel.swift
//  House
//
//  Created by Hanan Ahmed on 11/10/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation

// MARK: - Video Tutorial Response

struct GetVideoTutorialResponseModel: Codable {
    let videoTutorial: VideoTutorialDO?
}

// MARK: - VideoTutorial
 struct VideoTutorialDO: Codable {
    let videoURL: String?
    let thumbnailImageURL: String?
    let sectionKey: String?
    let numOfDays: Int?
    let watchKey: String?
    
    enum CodingKeys: String, CodingKey {
        case videoURL = "videoUrl"
        case thumbnailImageURL = "thumbnailImageUrl"
        case sectionKey = "sectionKey"
        case numOfDays
        case watchKey = "watchKey"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        videoURL = try values.decodeIfPresent(String.self, forKey: .videoURL)
        thumbnailImageURL = try values.decodeIfPresent(String.self, forKey: .thumbnailImageURL)
        sectionKey = try values.decodeIfPresent(String.self, forKey: .sectionKey)
        numOfDays = try values.decodeIfPresent(Int.self, forKey: .numOfDays)
        watchKey = try values.decodeIfPresent(String.self, forKey: .watchKey)
    }
}
