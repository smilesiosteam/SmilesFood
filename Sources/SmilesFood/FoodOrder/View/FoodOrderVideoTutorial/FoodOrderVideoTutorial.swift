//
//  FoodOrderVideoTutorial.swift
//  House
//
//  Created by Hanan Ahmed on 12/8/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesUtilities
import SmilesSharedModels

//MARK: -- Setup Tutorial
extension FoodOrderHomeViewController {
    
    func setupTutorialView() {
        self.ytPopUpView.isHidden = true
        self.ytPopUpView.ytViewDelegate = self
    }
    
    func setupVideoPlayerBackgroundView() {
        videoPlayerBackgroundView = UIView(frame: UIScreen.main.bounds)
        
        if let videoPlayerBackgroundView = videoPlayerBackgroundView {
            view.addSubview(videoPlayerBackgroundView)
        }
        
        videoPlayerBackgroundView?.backgroundColor = .systemBackground
        videoPlayerBackgroundView?.isHidden = true
        view?.bringSubviewToFront(ytPopUpView)
    }
    
    func showTutorialView(with videoPlayer: VideoTutorialDO?) {
        self.videoPlayerObj = videoPlayer
        if let thumbNail = videoPlayer?.thumbnailImageURL, !thumbNail.isEmpty {
            DispatchQueue.main.async {
                self.ytPopUpView.isHidden = false
                self.ytPopUpView.thumbImgView.setImageWithUrlString(thumbNail)
                self.isYTVideoLoadedOnce = true
            }
        } else {
            self.ytPopUpView.isHidden = true
        }
    }
}

//MARK: -- YoutubeViewDelegate
extension FoodOrderHomeViewController: YoutubeViewDelegate {
    
    func didTappedClose() {
        ytPopUpView.removeFromSuperview()
        
        videoPlayerBackgroundView?.isHidden = true
//        HouseConfig.registerPersonalizationEventRequest(withAccountType: GetEligibilityMatrixResponse.sharedInstance.accountType.asStringOrEmpty(),
//                                                        urlScheme: nil,
//                                                        offerId: videoPlayerObj?.watchKey,
//                                                        bannerType: nil,
//                                                        eventName: "tutorial_video_closed")
        
        SmilesCommonMethods.registerPersonalizationEvent(for: "tutorial_video_closed", offerId: videoPlayerObj?.watchKey, source: self.personalizationEventSource)
    }
    
    func didTappedExpand() {
        videoPlayerWidthConstraint.isActive = false
        videoPlayerHeightConstraint.isActive = false
        
        ytPopUpView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            ytPopUpView.topAnchor.constraint(equalTo: self.view.topAnchor),
            ytPopUpView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            ytPopUpView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            ytPopUpView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            ytPopUpView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0)
        ])
        
        ytPopUpView.layoutIfNeeded()
        
        ytPopUpView.playVideo(videoURL: videoPlayerObj?.videoURL)
        videoPlayerBackgroundView?.isHidden = false
        
//        HouseConfig.registerPersonalizationEventRequest(withAccountType: GetEligibilityMatrixResponse.sharedInstance.accountType.asStringOrEmpty(),
//                                                        urlScheme: nil,
//                                                        offerId: videoPlayerObj?.watchKey,
//                                                        bannerType: nil,
//                                                        eventName: "tutorial_video_played")
        
        SmilesCommonMethods.registerPersonalizationEvent(for: "tutorial_video_played", offerId: videoPlayerObj?.watchKey, source: self.personalizationEventSource)
    }
}
