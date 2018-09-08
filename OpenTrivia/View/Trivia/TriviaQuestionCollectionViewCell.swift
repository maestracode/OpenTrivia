//
//  TriviaQuestionCollectionViewCell.swift
//  OpenTrivia
//
//  Created by omaestra on 06/09/2018.
//  Copyright © 2018 Oswaldo Maestra. All rights reserved.
//

import UIKit

protocol TriviaQuestionCollectionViewCellDelegate: class {
    func optionSelected(question: Question, selectedAnswer: String) -> Bool
}

class TriviaQuestionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var questionCountLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answersStackView: UIStackView!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    weak var delegate: TriviaQuestionCollectionViewCellDelegate?
    
    var answers: [String]!
    var question: Question? {
        didSet {
            load(question: question)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        answersStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    private func load(question: Question?) {
        guard let question = question else { return }
        
        do {
            let questionTextAttributes = [
                NSAttributedStringKey.foregroundColor : UIColor.white,
                NSAttributedStringKey.font : UIFont.init(name: "HelveticaNeue-Medium", size: 24.0)!
                ] as [NSAttributedStringKey : Any]
            let decodedHtml = try NSAttributedString(HTMLString: question.question, attributes: questionTextAttributes)
            
            questionTextView.attributedText = decodedHtml
        } catch (let error) {
            print("[ERROR]: Error trying to decode HTML format. -> \(error.localizedDescription)")
            questionTextView.text = question.question
        }
        
        answers = question.incorrectAnswers
        answers.append(question.correctAnswer)
        answers.shuffle()
        
        for (index, answer) in answers.enumerated() {
            let button = UIButton(type: .system)
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.cornerRadius = 5.0
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            do {
                let answerTextAttributes = [
                    NSAttributedStringKey.foregroundColor : UIColor.white,
                    NSAttributedStringKey.font : UIFont.init(name: "HelveticaNeue-Medium", size: 17.0)!
                    ] as [NSAttributedStringKey : Any]
                
                let decodedHtml = try NSAttributedString(HTMLString: answer, attributes: answerTextAttributes)
                button.setAttributedTitle(decodedHtml, for: .normal)
            } catch (let error) {
                print("[ERROR]: Error trying to decode HTML format. -> \(error.localizedDescription)")
                button.setTitle(answer, for: .normal)
            }
            button.tag = index
            
            answersStackView.addArrangedSubview(button)
        }
    }
    
    private func displayAnswerResult(for question: Question, result: Bool) {
        let correctAnswerLabel = UILabel(frame: CGRect.zero)
        
        let textParagraphStyle = NSMutableParagraphStyle()
        textParagraphStyle.alignment = .right
        
        let answerTextAttributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.font : UIFont.init(name: "HelveticaNeue-Light", size: 15.0)!,
            NSAttributedStringKey.paragraphStyle: textParagraphStyle
            ] as [NSAttributedStringKey : Any]
        
        let answerText = result ? "Correct!" : "Correct answer: \(question.correctAnswer)"

        do {
            let decodedHtml = try NSAttributedString(HTMLString: answerText, attributes: answerTextAttributes)
            correctAnswerLabel.attributedText = decodedHtml
        } catch (let error) {
            print("[ERROR]: Error trying to decode HTML format. -> \(error.localizedDescription)")
            correctAnswerLabel.text = "Correct answer: \(question.correctAnswer)"
        }
        self.answersStackView.addArrangedSubview(correctAnswerLabel)
    }
    
    @IBAction func optionSelected(_ sender: UIButton) {
        guard let question = self.question else { return }
        self.answersStackView.arrangedSubviews.forEach({ $0.isUserInteractionEnabled = false })
        
        guard let result = delegate?.optionSelected(question: question, selectedAnswer: self.answers[sender.tag]) else { return }
        
        if result {
            sender.backgroundColor = UIColor.init(red: 108/255, green: 191/255, blue: 132/255, alpha: 1.0)
        } else {
            sender.backgroundColor = UIColor.init(red: 255/255, green: 105/255, blue: 104/255, alpha: 1.0)
        }
        displayAnswerResult(for: question, result: result)
    }
}
