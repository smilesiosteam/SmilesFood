//
//  FoodOrderAbandonedCart.swift
//  House
//
//  Created by Hanan Ahmed on 12/8/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesUtilities
import SmilesSharedModels

extension FoodOrderHomeViewController {
    
    func addShadowToAbandonedCart() {
        stickyBottomView.addShadowToSelf(offset: CGSize(width: 0, height: -1), color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.1), radius: 1.0, opacity: 5)
    }
    
    func bottomStickView(isHide: Bool) {
        stickyBottomView.isHidden = isHide
        pageControl.isHidden = isHide
        pageControllBottomView.isHidden = isHide
    }
    
    func reloadStickyCollection() {
        if stickyCollectionData.count > 0 {
            stickyCollectionData.removeAll()
            stickyBottomCollectionView.reloadData()
        }
    }
    
    func updateAbandonedCartAndOrderTrackingView(withAbandonedCart cart: Abandoned?, andTrackingDetails: [TrackOrderOnMapResponseModelOrderTrackingDetail]?, timeout: Int?) {
        var stickyData = [BaseRowModel]()
        
        if let cart = cart {
            selectedAbandonedCart = cart
            let rowModel = BaseRowModel()
            
            let model = AbandonCartCollectionViewCellModel()
            model.title = cart.restaurantName ?? ""
            model.subTitle = String(format: "HaveItemsIn".localizedString, cart.itemCount ?? "0")
            model.icon = cart.imageURL ?? ""
            model.delegate = self
            
            rowModel.rowCellIdentifier = "AbandonCartCollectionViewCell"
            rowModel.rowHeight = UITableView.automaticDimension
            rowModel.rowValue = model
            
            stickyData.append(rowModel)
        }
        
        if let orderTrackingDetails = andTrackingDetails {
            for orderDetails in orderTrackingDetails {
                let rowModel = BaseRowModel()
                
                let model = OrderStatusCollectionViewCellModel()
                model.delegate = self
                model.selectedOrderObject = orderDetails.orderDetails
                model.cellWidth = Double(UIScreen.main.bounds.width)
                rowModel.rowCellIdentifier = "OrderStatusCollectionViewCell"
                rowModel.rowHeight = UITableView.automaticDimension
                rowModel.rowValue = model
                
                stickyData.append(rowModel)
            }
        }
        
        if stickyData.count > 0 {
            if stickyCollectionData.count > 0 {
                stickyCollectionData.removeAll()
            }
            stickyCollectionData = stickyData
        }
        timerInvalidate()
        
        if let refreshTime = timeout {
            if refreshTime > 0 {
                statusUpdateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(refreshTime), target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
            } else {
                statusUpdateTimer?.invalidate()
            }
        }
        
        stickyBottomCollectionView.reloadData()
        
        pageControl.numberOfPages = stickyCollectionData.count
        
        if stickyCollectionData.count > 0 {
            bottomStickView(isHide: false)
        } else {
            bottomStickView(isHide: true)
        }
        
        if pageControl.numberOfPages >= 2 {
            pageControl.isHidden = false
        } else {
            pageControl.isHidden = true
        }
    }
    
    @objc func runTimedCode() {
        statusUpdateTimer?.invalidate()
        self.input.send(.getAbandonedCart)
    }
    
    func timerInvalidate() {
        if statusUpdateTimer != nil {
            statusUpdateTimer?.invalidate()
            statusUpdateTimer = nil
        }
    }
    
    func abandonedCartRemoved() {
        if abandonedCartActionType == .VIEW {
            self.input.send(.getAbandonedCart)
            self.input.send(.routeToRestaurantDetail(
                restaurant: anotherRestaurantSelected ?? Restaurant(),
                isViewCart: false)
            )
        } else {
            if stickyCollectionData.count > 0 {
                stickyCollectionData.remove(at: 0)
                stickyBottomCollectionView.reloadData()
            }
            
            if abandonedCartActionType == .REORDER {
                self.callReOrderService(with: self.reOrderID ?? "")
            } else {
                self.input.send(.getAbandonedCart)
            }
        }
    }
    
    func removeBottomSheet(forAnotherRestaurant restaurant: Restaurant) {
        abandonedCartActionType = .VIEW
        anotherRestaurantSelected = restaurant
        showPickupPopUp(abandonedCartActionType: .VIEW, abandonedObj: selectedAbandonedCart)
    }
    
    func showPickupPopUp(abandonedCartActionType: AbandonedCartActionType, abandonedObj: Abandoned?) {
        let title = String(format: "HaveItemsIn".localizedString, abandonedObj?.itemCount ?? "0")
        var subtitle: String = ""
        let rightButton = "remove".localizedString
        
        if abandonedCartActionType == .REMOVE || abandonedCartActionType == .REORDER {
            subtitle = String(format: "WantToRemoveItems".localizedString, abandonedObj?.restaurantName ?? "")
        } else {
            subtitle = String(format: "AddItemsToAnotherRestaurant".localizedString, abandonedObj?.restaurantName ?? "", anotherRestaurantSelected?.restaurantName ?? "")
        }
        
        let actionSheetItems = ActionSheetPresenter.createActionSheetForSwitchView(title: title, subtitle: subtitle, leftButton: "KeepItems".localizedString, rightButton: rightButton, delegate: self)
        
        actionSheet = actionSheetItems.0
        actionSheet?.showInView(navigationController?.view ?? view, items: actionSheetItems.1, closeBlock: {})
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension FoodOrderHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickyCollectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let item = stickyCollectionData[safe: indexPath.row] {
            switch item.rowCellIdentifier {
            case "AbandonCartCollectionViewCell":
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.rowCellIdentifier, for: indexPath) as? AbandonCartCollectionViewCell {
                    if let model = item.rowValue as? AbandonCartCollectionViewCellModel {
                        cell.configureCell(with: model)
                    }
                    return cell
                }
                
            case "OrderStatusCollectionViewCell":
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.rowCellIdentifier, for: indexPath) as? OrderStatusCollectionViewCell {
                    if let model = item.rowValue as? OrderStatusCollectionViewCellModel {
                        cell.configureCell(with: model)
                    }
                    return cell
                }
                
            default:
                break
            }
            
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 72)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let total = scrollView.contentSize.width - scrollView.bounds.width
        let offset = scrollView.contentOffset.x
        let percent = Double(offset / total)
        
        let progress = percent * Double(stickyCollectionData.count - 1)
        pageControl.progress = progress
        self.adjustTopHeader(scrollView)
        if scrollView.contentOffset.y < 0.0 {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                let deltaY = CGFloat(fabsf(Float(scrollView.contentOffset.y)) - fabsf(Float(lastContentOffset.y)))
                cell.frame = CGRect(x: 0.0, y: scrollView.contentOffset.y, width: cell.frame.size.width, height: cell.frame.size.height + deltaY)
                lastContentOffset = scrollView.contentOffset
            }
        }
        
        if let indexPath = tableView.indexPath(for: tableView.visibleCells.first ?? UITableViewCell()) {
            let backgroundColor = self.foodSections?.sectionDetails?[safe: indexPath.section]?.backgroundColor
            topHeaderView.setBackgroundColorForTabsCurveView(color: UIColor(hexString: backgroundColor.asStringOrEmpty()))
        }
    }
    func adjustTopHeader(_ scrollView: UIScrollView) {
        guard isHeaderExpanding == false else {return}
        if let tableView = scrollView as? UITableView {
            let items = (0..<tableView.numberOfSections).reduce(into: 0) { partialResult, sectionIndex in
                partialResult += tableView.numberOfRows(inSection: sectionIndex)
            }
            if items == 0 {
                return
            }
        }
        let isAlreadyCompact = !topHeaderView.bodyViewCompact.isHidden
        let compact = scrollView.contentOffset.y > 150
        if compact != isAlreadyCompact {
            isHeaderExpanding = true
            topHeaderView.adjustUI(compact: compact)
            topHeaderView.view_container.backgroundColor = compact ? .white : .appRevampEnableStateColor
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
                self.isHeaderExpanding = false
            }
        }
    }
}

// MARK: - ActionSheetButtonsDelegate
extension FoodOrderHomeViewController: ActionSheetButtonsDelegate {
    func rightButtonTaapped() {
        actionSheet?.dismiss()
        
        if let abandonedCart = selectedAbandonedCart {
            self.input.send(.removeAbandonedCart(abandonedCart: abandonedCart))
        }
        
        if actionSheet?.tag == cartActionSheetTag.orderPriceChanged.rawValue {
            let restaurantObj = Restaurant()
            restaurantObj.restaurantId = self.reOrderRestaurantID
            
            self.redirectToRestaurantDetailController(restaurant: restaurantObj, isFromReOrder: true)
        }
    }
    
    func leftButtonTaapped() {
        actionSheet?.dismiss()
        if abandonedCartActionType == .REMOVE {
        } else if abandonedCartActionType == .REORDER {
            let restaurantObj = Restaurant()
            restaurantObj.restaurantId = self.reOrderRestaurantID
            
            self.redirectToRestaurantDetailController(restaurant: restaurantObj, isFromReOrder: true)
        }
    }
}

// MARK: - AbandonedCartAction
extension FoodOrderHomeViewController: AbandonCartCollectionViewCellDelegate {
    func abandonCartViewButtonClicked() {
        
        if selectedAbandonedCart?.orderType == "PICK_UP" {
            OrderInfoModel.shared.orderType = .PICK_UP
        } else {
            OrderInfoModel.shared.orderType = .DELIVERY
        }
        
        self.input.send(.viewCartDetail(restaurantId: selectedAbandonedCart?.restaurantID))
    }
    
    func abandonCartRemoveButtonClicked() {
        abandonedCartActionType = .REMOVE
        showPickupPopUp(abandonedCartActionType: .REMOVE, abandonedObj: selectedAbandonedCart)
    }
    
}

// MARK: - OrderStatusCollectionViewCellDelegate
extension FoodOrderHomeViewController: OrderStatusCollectionViewCellDelegate {
    func orderStatusYesButtonClicked(orderDetail: OrderDetail) {
        if let orderId = orderDetail.orderId {
            timerInvalidate()
            self.input.send(.setOrderStatus(orderId: "\(orderId)"))
        }
    }
    
    func orderStatusNoButtonClicked(orderDetail: OrderDetail) {
        if let orderId = orderDetail.orderId, let orderNumber = orderDetail.orderNumber {
            timerInvalidate()
            self.input.send(.getLiveChatUrl(orderId: "\(orderId)", orderNumber: orderNumber))
        }
    }
    
    func orderStatusTrackButtonClicked(orderDetail: OrderDetail) {
        if let orderId = orderDetail.orderId, let orderNumber = orderDetail.orderNumber {
            let orderStatus = OrderStatus(rawValue: orderDetail.orderStatus ?? 0)
            
            switch orderStatus {
            case .delivered, .orderPickedUp:
                if let ratingStatus = orderDetail.ratingStatus {
                    if !ratingStatus {
                        self.input.send(.getOrderRating(orderId: "\(orderId)", trackingStatus: orderDetail.liveTracking.asBoolOrFalse(), restaurantId: orderDetail.restaurantId.asStringOrEmpty(), ratingType: "overall", contentType: "landing"))
                    } else {
                        self.redirectToOrderHistory(orderDetail.restaurantId.asStringOrEmpty(), orderId: "\(orderId)")
                    }
                } else {
                    self.redirectToOrderHistory(orderDetail.restaurantId.asStringOrEmpty(), orderId: "\(orderId)")
                }
            default:
                self.redirectToTrackingScreen(with: "\(orderId)", orderNumber: orderNumber, isLiveTracking: (orderDetail.trackingType ?? "") != "no")
            }
        }
    }
}
