//
//  LikedRoadmapsView.swift
//  macroChallengeApp
//
//  Created by Carolina Ortega on 20/09/22.
//

import Foundation
import UIKit
import SnapKit

class LikedRoadmapsView: UIView {
    let designSystem: DesignSystem = DefaultDesignSystem.shared
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    lazy var likedRoadmapsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - designSystem.spacing.xLargePositive, height: 292)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = designSystem.spacing.largePositive
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.register(RoadmapExploreCollectionViewCell.self, forCellWithReuseIdentifier: RoadmapExploreCollectionViewCell.identifier)
        collectionView.isScrollEnabled = true
        collectionView.isPagingEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = 16
        return collectionView
    }()
    
    func setup() {
        self.backgroundColor = designSystem.palette.backgroundPrimary
        self.addSubview(likedRoadmapsCollectionView)
        setupConstraints()
    }
    
    func setupConstraints() {
        likedRoadmapsCollectionView.snp.makeConstraints { make in
            make.topMargin.equalToSuperview()
            make.trailing.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }

    }
}
extension LikedRoadmapsView {
    func bindCollectionView(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource) {
        likedRoadmapsCollectionView.delegate = delegate
        likedRoadmapsCollectionView.dataSource = dataSource
    }
    
}
