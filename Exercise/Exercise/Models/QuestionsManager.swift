//  QuestionsManager

import Foundation
import UIKit
protocol QuestionsManagerDelegate {
    func didUpdateQuestion(question: AttributedString, answers: [Answer], index: Int, length: Int)
    func didFailWithError(error: Error)
    func endGame(score: Int)
    func changeTime(time: Int)
}

class TriviaManager {
    
    var delegate: QuestionsManagerDelegate?
    let numOfQuestions: Int = 10
    var index: Int = 0
    private(set) var trivia: [Trivia.Result] = []
    var answerSelected = false
    private(set) var question: AttributedString = ""
    private(set) var answerChoices: [Answer] = []
    var score: Int = 0
    var correctAnswer = ""
    
    var timer = Timer()
    var time = 60 {
        didSet{
            self.delegate?.changeTime(time: time)
        }
    }

    // Asynchronous HTTP request to get the trivia questions and answers
    func fetchTrivia() async {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=\(numOfQuestions)") else { fatalError("Missing URL") }
        
        let urlRequest = URLRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(Trivia.self, from: data)
            self.trivia = decodedData.results
            self.index = 0
            self.setQuestion()
        } catch {
            print("Error fetching trivia: \(error)")
        }
    }
    
    func goToNextQuestion() {
        if index+1 < numOfQuestions {
            index += 1
            setQuestion()
        } else {
            timer.invalidate()
            self.delegate?.endGame(score: score)
        }
        
    }
    
    func setQuestion() {
        answerSelected = false
        if index < numOfQuestions {
            let currentTriviaQuestion = trivia[index]
            question = currentTriviaQuestion.formattedQuestion
            answerChoices = currentTriviaQuestion.answers
            correctAnswer = currentTriviaQuestion.correctAnswer
            print(correctAnswer)
            delegate?.didUpdateQuestion(question: question, answers: answerChoices,index: index, length: numOfQuestions)
        }
    }
    
    func selectAnswer(answer: Answer) {
        answerSelected = true
        if answer.isCorrect {
            score += 1
        }
    }
    
    @objc func tick() {
        time -= 1
        if time == 0{
            timer.invalidate()
            delegate?.endGame(score: score)
        }
    }
}

