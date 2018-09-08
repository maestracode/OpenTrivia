//
//  OpenTriviaAPI.swift
//  OpenTrivia
//
//  Created by omaestra on 05/09/2018.
//  Copyright © 2018 Oswaldo Maestra. All rights reserved.
//

import Foundation
import Siesta

internal class OpenTriviaAPI: Siesta.Service {
    
    private let baseUrl = "https://opentdb.com"
    
    static let sharedInstance = OpenTriviaAPI()
    
    fileprivate init() {
        super.init(baseURL: baseUrl, standardTransformers: [.text, .image])
        
        #if DEBUG
        // Bare-bones logging of which network calls Siesta makes:
        SiestaLog.Category.enabled = [.network]
        
        // For more info about how Siesta decides whether to make a network call,
        // and which state updates it broadcasts to the app:
        SiestaLog.Category.enabled = SiestaLog.Category.common
        // For the gory details of what Siesta’s up to:
        //LogCategory.enabled = LogCategory.all
        // To dump all requests and responses:
        // (Warning: may cause Xcode console overheating)
        //LogCategory.enabled = LogCategory.all
        #endif
        
        // –––––– Global configuration ––––––
        let jsonDecoder = JSONDecoder()
        
        // –––––– Auth configuration ––––––
        // Note the "**" pattern, which makes this config apply only to subpaths of baseURL.
        // This prevents accidental credential leakage to untrusted servers.
        configure("**") {
            // This header configuration gets reapplied whenever the user logs in or out.
            // How? See the authToken property’s didSet.
            $0.headers["Authorization"] = self.authToken
        }
        
        configureTransformer("/api_category.php") {
            try jsonDecoder.decode(CategoryResults<Category>.self, from: $0.content).categories
        }
        configureTransformer("/api.php") {
            try jsonDecoder.decode(QuestionResults<Question>.self, from: $0.content).results
        }
    }
    
    var isAuthenticated: Bool {
        return authToken != nil
    }
    
    var authToken: String? {
        didSet {
            // These two calls are almost always necessary when you have changing auth for your API:
            invalidateConfiguration()  // So that future requests for existing resources pick up config change
            wipeResources()            // Scrub all unauthenticated data
            // Note that wipeResources() broadcasts a “no data” event to all observers of all resources.
            // Therefore, if your UI diligently observes all the resources it displays, this call prevents sensitive
            // data from lingering in the UI after logout.
        }
    }
    
    func triviaCategoriesList() -> Siesta.Resource {
        return resource("/api_category.php")
    }
    
    func getTriviaQuestions(from category: Category, amount: Int) -> Siesta.Resource {
        return resource("/api.php")
        .withParam("category", "\(category.id)")
        .withParam("amount", "\(amount)")
    }
}
