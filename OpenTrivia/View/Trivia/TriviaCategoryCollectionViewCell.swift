//
//  TriviaCategoryCollectionViewCell.swift
//  OpenTrivia
//
//  Created by omaestra on 05/09/2018.
//  Copyright © 2018 Oswaldo Maestra. All rights reserved.
//

import UIKit
import Kingfisher

class TriviaCategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    var category: Category? {
        didSet {
            setValues(for: category)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func setValues(for category: Category?) {
        categoryImageView.setImageForName(string: category!.name, circular: true, textAttributes: nil) 
        categoryTitleLabel.text = category?.name
    }

}
