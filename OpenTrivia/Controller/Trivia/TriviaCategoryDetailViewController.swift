//
//  TriviaCategoryDetailViewController.swift
//  OpenTrivia
//
//  Created by omaestra on 05/09/2018.
//  Copyright © 2018 Oswaldo Maestra. All rights reserved.
//

import UIKit
import Siesta

class TriviaCategoryDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var triviaCategoryImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var triviaInstructionsTextView: UITextView!
    
    var statusOverlay = ResourceStatusOverlay()
    
    var category: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = category?.name
        triviaCategoryImageView.setImageForName(string: category!.name, circular: true, textAttributes: nil)
        
        statusOverlay.embed(in: self)
        
        triviaInstructionsTextView.text = """
        - Each question has an specific points value depending on its difficulty: hard (3), medium (2), easy (1).
        - Each question has an specific time value to respond depending on its difficulty: hard (15sg), medium (10sg), easy (8sg).
        """
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        progressView.isHidden = true
        progressView.progress = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        statusOverlay.positionToCover(self.playButton)
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        guard let category = self.category else { return }
        progressView.isHidden = false
        OpenTriviaAPI.sharedInstance.getTriviaQuestions(from: category, amount: 10)
            .addObserver(statusOverlay)
            .load()
            .onProgress({ [weak self] (progress) in
                self?.progressView.progress = Float(progress)
            })
            .onSuccess { (entity) in
                let questions: [Question]? = entity.typedContent()
                self.performSegue(withIdentifier: "toTriviaGame", sender: questions)
            }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTriviaGame" {
            guard let viewController = (segue.destination as! UINavigationController).topViewController as?  TriviaGameViewController else { return }
            guard let questions = sender as? [Question] else { return }
            
            viewController.questions = questions
        }
    }
}
