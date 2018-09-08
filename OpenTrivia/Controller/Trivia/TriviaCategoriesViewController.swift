//
//  TriviaCategoriesViewController.swift
//  OpenTrivia
//
//  Created by omaestra on 04/09/2018.
//  Copyright © 2018 Oswaldo Maestra. All rights reserved.
//

import UIKit
import Siesta

class TriviaCategoriesViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var triviaCategoriesCollectionView: UICollectionView!
    @IBOutlet weak var userImageView: UIImageView!
    
    var statusOverlay = ResourceStatusOverlay()
    
    var triviaCategoriesResource: Siesta.Resource? {
        didSet {
            oldValue?.removeObservers(ownedBy: self)
            
            triviaCategoriesResource?
                .addObserver(self)
                .addObserver(statusOverlay, owner: self)
                .loadIfNeeded()
        }
    }
    
    var categories: [Category]? {
        didSet {
            triviaCategoriesCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Open Trivia"
        
        titleLabel.text = "Welcome\n\(UserDefaults.standard.string(forKey: "username") ?? "")!"
        subtitleLabel.text = "Choose a category to begin"
        
        triviaCategoriesCollectionView.delegate = self
        triviaCategoriesCollectionView.dataSource = self
        
        triviaCategoriesCollectionView.register(TriviaCategoryCollectionViewCell.nib, forCellWithReuseIdentifier: TriviaCategoryCollectionViewCell.identifier)
        
        statusOverlay.embed(in: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        triviaCategoriesResource = OpenTriviaAPI.sharedInstance.triviaCategoriesList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        statusOverlay.positionToCover(triviaCategoriesCollectionView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTriviaCategory" {
            guard let viewController = segue.destination as? TriviaCategoryDetailViewController else { return }
            
            viewController.category = sender as? Category
        }
    }

}

extension TriviaCategoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let yourWidth = collectionView.bounds.width/2 - 48
        let yourHeight = yourWidth + 44
        
//        let attributes = [
//            NSAttributedStringKey.foregroundColor : UIColor.darkGray,
//            NSAttributedStringKey.font : UIFont.init(name: "HelveticaNeue", size: 17.0)!
//            ] as [NSAttributedStringKey : Any]
//
//        if let category = categories?[indexPath.row] {
//            let estimatedFrame = NSString(string: category.name).boundingRect(with: CGSize(width: yourWidth, height: yourHeight), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
//
//            return CGSize(width: yourWidth, height: estimatedFrame.height + yourHeight)
//        }
        
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TriviaCategoryCollectionViewCell.identifier, for: indexPath) as! TriviaCategoryCollectionViewCell
        
        guard let category = categories?[indexPath.row] else { return cell }
        cell.category = category
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let category = categories?[indexPath.row] else { return }
        performSegue(withIdentifier: "toTriviaCategory", sender: category)
    }
    
}

extension TriviaCategoriesViewController: ResourceObserver {
    func resourceChanged(_ resource: Siesta.Resource, event: ResourceEvent) {
        categories = triviaCategoriesResource?.latestData?.typedContent()
    }
}
