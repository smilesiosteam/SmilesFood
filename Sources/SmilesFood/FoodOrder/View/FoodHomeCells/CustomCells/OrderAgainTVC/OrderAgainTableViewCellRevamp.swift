//
//  OrderAgainTableViewCell.swift
//  House
//
//  Created by Shahroze Zaheer on 11/4/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import UIKit

class OrderAgainTableViewCellRevamp: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var collectionsData: [OrderListDO]?{
        didSet{
            self.collectionView?.reloadData()
        }
    }
    var callBack: ((OrderListDO) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: String(describing: OrderAgainCollectionViewCellRevamp.self), bundle: nil), forCellWithReuseIdentifier: String(describing: OrderAgainCollectionViewCellRevamp.self))
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = setupCollectionViewLayout()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCollectionViewLayout() ->  UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16)
            let groupSize =  NSCollectionLayoutSize(widthDimension: .absolute(132), heightDimension: .absolute(180))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets.leading = 16
            return section
        }
        
        return layout
    }
    
    func setBackGroundColor(color: UIColor) {
        mainView.backgroundColor = color
    }
}

extension OrderAgainTableViewCellRevamp: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionsData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let data = collectionsData?[indexPath.row] {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderAgainCollectionViewCellRevamp", for: indexPath) as? OrderAgainCollectionViewCellRevamp else {return UICollectionViewCell()}
            cell.configureCellWithData(data: data)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let data = collectionsData?[indexPath.row] {
            callBack?(data)
        }
    }
}
