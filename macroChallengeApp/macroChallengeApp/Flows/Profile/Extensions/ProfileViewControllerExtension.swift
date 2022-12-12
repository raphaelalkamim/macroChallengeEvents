//
//  ExtensionProfileViewController.swift
//  macroChallengeApp
//
//  Created by Carolina Ortega on 15/09/22.
//

import Foundation
import UIKit

extension ProfileViewController {
    func setupProfileView() {
        self.setupGestures()
        self.setupNavButton()
        profileView.updateConstraintsCollection()
        profileView.bindColletionView(delegate: self, dataSource: self)
    }
    func setupGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        profileView.myRoadmapCollectionView.addGestureRecognizer(longPress)
    }
    func setupNavButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(profileSettings))
    }
    // MARK: Long press and delete
    @objc public func handleLongPress(sender: UILongPressGestureRecognizer) {
        network.startMonitoring()
        if sender.state == .began {
            let touchPoint = sender.location(in: profileView.myRoadmapCollectionView)
            if let indexPath = profileView.myRoadmapCollectionView.indexPathForItem(at: touchPoint) {
                if roadmaps.isEmpty || !network.isReachable {
                    let action = UIAlertController(title: "Can't delete", message: nil, preferredStyle: .actionSheet)
                    action.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] _ in
                        self?.profileView.myRoadmapCollectionView.reloadData()
                    }))
                    present(action, animated: true)
                } else {
                    let action = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
                    
                    let roadmapName = "'\(roadmaps[indexPath.item].name ?? "NONE")'"
                    
                    let titleAtt = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 16)]
                    let title = "Delete all content from".localized()
                    let string = NSAttributedString(string: "\(title) \(roadmapName)", attributes: titleAtt as [NSAttributedString.Key: Any])
                    action.setValue(string, forKey: "attributedTitle")
                    
                    let subtitleAtt = [NSAttributedString.Key.font: UIFont(name: "Avenir-Roman", size: 16)]
                    let subtitleString = NSAttributedString(string: "The content cannot be recovered.".localized(), attributes: subtitleAtt as [NSAttributedString.Key: Any])
                    action.setValue(subtitleString, forKey: "attributedMessage")
                    
                    action.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { [weak self] _ in
                        do {
                            try RoadmapRepository.shared.deleteRoadmap(roadmap: self!.roadmaps[indexPath.row])
                        } catch { print(error) }
                        self?.profileView.myRoadmapCollectionView.reloadData()
                    }))
                    action.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
                    action.view.tintColor = .accent
                    present(action, animated: true)
                    
                }
                navigationController?.navigationBar.prefersLargeTitles = true
            }
        }
    }
}

extension ProfileViewController: UICollectionViewDelegate {
}

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        profileView.emptyState()
        return roadmaps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var openRoadmap = roadmaps[indexPath.row]
        if openRoadmap.isShared {
            // chama o roadmap do back
            DataManager.shared.getRoadmapById(roadmapId: Int(roadmaps[indexPath.row].id)) { backRoadmap in
                if let backRoadmap = backRoadmap {
                    openRoadmap = RoadmapRepository.shared.updateFromBackend(editRoadmap: self.roadmaps[indexPath.row], roadmap: backRoadmap)
                    self.coordinator?.openRoadmap(roadmap: openRoadmap )
                } else {
                    do {
                        try RoadmapRepository.shared.deleteRoadmap(roadmap: openRoadmap)
                        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                        alert.view.tintColor = .accent
                        let titleAtt = [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 18)]
                        let string = NSAttributedString(string: "This itinerary has been deleted by another user".localized(), attributes: titleAtt as [NSAttributedString.Key: Any])
                        alert.setValue(string, forKey: "attributedMessage")
                        
                        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
                        }))
                        self.coordinator?.showAlertController(alert: alert)
                    } catch {
                        print(error)
                    }
                }
            }
        } else {
            self.coordinator?.openRoadmap(roadmap: openRoadmap)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCell.identifier, for: indexPath) as? ProfileCollectionViewCell else {
            preconditionFailure("Cell not find")
        }
        let isNew = false
        UserDefaults.standard.bool(forKey: "isPublic")
        cell.setup(name: roadmaps[indexPath.row].name ?? "Erro", image: roadmaps[indexPath.row].imageId ?? "floripa", isNew: isNew)
        cell.setupImage(imageId: roadmaps[indexPath.row].imageId ?? "defaultCover", category: roadmaps[indexPath.row].category ?? "City")
        if roadmaps[indexPath.row].isPublic == false {
            cell.likeImage.image = UIImage(systemName: "lock.fill")
            UserDefaults.standard.set(false, forKey: "isPublic")
            cell.likeLabel.isHidden = true
        } else {
            cell.likeLabel.isHidden = false
            UserDefaults.standard.set(true, forKey: "isPublic")
            cell.likeImage.image = UIImage(systemName: "heart.fill")
            cell.likeLabel.text = String(roadmaps[indexPath.row].likesCount)
        }
        cell.setupAnchors()
        return cell
    }
}
