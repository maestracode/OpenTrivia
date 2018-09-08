//
//  Question.swift
//  OpenTrivia
//
//  Created by omaestra on 05/09/2018.
//  Copyright © 2018 Oswaldo Maestra. All rights reserved.
//

import Foundation

enum QuestionType: String, Decodable {
    case multiple = "multiple"
    case boolean = "boolean"
}

enum QuestionDifficulty: String, Decodable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
}

class Question: NSObject, Decodable {
    var category: String
    var type: QuestionType
    var difficulty: QuestionDifficulty
    var question: String
    var correctAnswer: String
    var incorrectAnswers: [String]
    var points: Int {
        switch difficulty {
        case .easy:
            return 1
        case .medium:
            return 2
        case .hard:
            return 3
        }
    }
    var time: Int {
        switch difficulty {
        case .easy:
            return 5
        case .medium:
            return 10
        case .hard:
            return 15
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case category, type, question, difficulty
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        category = try container.decode(String.self, forKey: .category)
        type = try container.decode(QuestionType.self, forKey: .type)
        difficulty = try container.decode(QuestionDifficulty.self, forKey: .difficulty)
        question = try container.decode(String.self, forKey: .question)
        correctAnswer = try container.decode(String.self, forKey: .correctAnswer)
        incorrectAnswers = try container.decode([String].self, forKey: .incorrectAnswers)
    }
}

struct QuestionResults<T: Decodable>: Decodable {
    let results: [T]
    let responseCode: Int
    
    private enum CodingKeys: String, CodingKey {
        case results
        case responseCode = "response_code"
    }
}
