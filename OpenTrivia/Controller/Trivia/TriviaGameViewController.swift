//
//  TriviaGameViewController.swift
//  OpenTrivia
//
//  Created by omaestra on 06/09/2018.
//  Copyright © 2018 Oswaldo Maestra. All rights reserved.
//

import UIKit

class TriviaGameViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    let pointsBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "0 Points", style: .plain, target: nil, action: nil)
        barButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.font : UIFont.init(name: "HelveticaNeue-Light", size: 15.0)!], for: .normal)
        barButtonItem.tintColor = UIColor.white
        return barButtonItem
    }()
    
    let circularCountdownTimer: SRCountdownTimer = {
        let countdownTimer = SRCountdownTimer(frame: CGRect.zero)
        countdownTimer.labelFont = UIFont(name: "HelveticaNeue-Light", size: 24.0)
        countdownTimer.lineColor = UIColor.white
        countdownTimer.backgroundColor = UIColor.clear
        countdownTimer.labelTextColor = UIColor.white
        countdownTimer.timerFinishingText = "0"
        countdownTimer.lineWidth = 4
        return countdownTimer
    }()
    
    var questions: [Question]!
    var currentQuestion: Question?
    var answers: [String]!
    var points: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.transparentNavigationBar()
        navigationController?.navigationBar.barStyle = .black
        
        toolbar.transparentToolbar()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(TriviaQuestionCollectionViewCell.nib, forCellWithReuseIdentifier: TriviaQuestionCollectionViewCell.identifier)
        
        self.currentQuestion = questions.first
        
        nextBarButtonItem.isEnabled = false
        
        circularCountdownTimer.delegate = self
        
        self.navigationItem.rightBarButtonItem = pointsBarButtonItem
        
        // Add countdown to toolbar??
//        let circularCountdown = UIBarButtonItem(customView: circularCountdownTimer)
//        self.toolbar.items?.insert(circularCountdown, at: 0)
        circularCountdownTimer.frame = CGRect(origin: CGPoint(x: toolbar.center.x - 40, y: toolbar.center.y + 50), size: CGSize(width: 80, height: 80))
        self.view.addSubview(circularCountdownTimer)
        circularCountdownTimer.start(beginingValue: (currentQuestion?.time)!, interval: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func check(answer: String, for question: Question) -> Bool {
        return answer == question.correctAnswer
    }
    
    private func invalidateCurrentQuestion() {
        if let currentCell = collectionView.visibleCells.first as? TriviaQuestionCollectionViewCell {
            currentCell.answersStackView.arrangedSubviews.filter({ $0 is UIButton }).forEach({
                ($0 as! UIButton).isEnabled = false
                ($0 as! UIButton).backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            })
            nextBarButtonItem.isEnabled = true
            
            let resultMessageLabel = UILabel(frame: CGRect.zero)
            
            let textParagraphStyle = NSMutableParagraphStyle()
            textParagraphStyle.alignment = .right
            
            let attributes = [
                NSAttributedStringKey.foregroundColor : UIColor.white,
                NSAttributedStringKey.font : UIFont.init(name: "HelveticaNeue-Light", size: 15.0)!,
                NSAttributedStringKey.paragraphStyle: textParagraphStyle
                ] as [NSAttributedStringKey : Any]
            
            resultMessageLabel.attributedText = NSAttributedString(string: "Oh! You missed it! :(", attributes: attributes)
            
            currentCell.answersStackView.addArrangedSubview(resultMessageLabel)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        if let currentQuestion = self.currentQuestion, let currentQuestionIndex = questions.index(of: currentQuestion), questions.count - 1 > currentQuestionIndex {
            
            self.currentQuestion = questions[currentQuestionIndex + 1]
            collectionView.scrollToItem(at: IndexPath(row: currentQuestionIndex + 1, section: 0), at: .right, animated: true)
            if self.currentQuestion == questions.last {
                nextBarButtonItem.title = "Finish"
            }
            
            circularCountdownTimer.pause()
            circularCountdownTimer.start(beginingValue: currentQuestion.time, interval: 1)
        } else if self.currentQuestion == questions.last {
            self.dismiss(animated: true, completion: nil)
        }
        
        nextBarButtonItem.isEnabled = false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TriviaGameViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.questions?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let yourWidth = collectionView.bounds.width
        let yourHeight = collectionView.bounds.height
        
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TriviaQuestionCollectionViewCell.identifier, for: indexPath) as! TriviaQuestionCollectionViewCell
        
        cell.delegate = self
        
        let question = self.questions[indexPath.row]

        cell.question = question
        
        if let currentQuestionIndex = self.questions.index(of: question), questions.count > currentQuestionIndex {
            cell.questionCountLabel.text = "Question \(currentQuestionIndex + 1)/\(questions.count)"
        } else {
            cell.questionCountLabel.text = "Question -/\(questions.count)"
        }
        
        return cell
    }
}

extension TriviaGameViewController: TriviaQuestionCollectionViewCellDelegate {
    func optionSelected(question: Question, selectedAnswer: String) -> Bool {
        nextBarButtonItem.isEnabled = true
        circularCountdownTimer.pause()
        let result = check(answer: selectedAnswer, for: question)
        if result {
            points += question.points
            pointsBarButtonItem.title = "\(points) Points"
        }
        return check(answer: selectedAnswer, for: question)
    }
}

extension TriviaGameViewController: SRCountdownTimerDelegate {
    func timerDidStart() {
        
    }
    
    func timerDidEnd() {
        invalidateCurrentQuestion()
    }
}
