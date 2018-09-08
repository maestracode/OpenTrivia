//
//  Category.swift
//  OpenTrivia
//
//  Created by omaestra on 05/09/2018.
//  Copyright © 2018 Oswaldo Maestra. All rights reserved.
//

import Foundation
import UIKit

class Category: Decodable {
    var id: Int
    var name: String
    var image: UIImage?
    
    private enum CodingKeys: String, CodingKey {
        case id, name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
}

struct CategoryResults<T: Decodable>: Decodable {
    let categories: [T]
    
    private enum CodingKeys: String, CodingKey {
        case categories = "trivia_categories"
    }
}
