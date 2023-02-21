//
//  ViewController.swift
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var buttonsContainer: UIStackView!
    
    var triviaManager = TriviaManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initGame()
    }
    
    func initGame(){
        designQuestionLabel()
        
        triviaManager.delegate = self
        
        Task {
            await triviaManager.fetchTrivia()
        }
        triviaManager.time = 60

        triviaManager.timer = Timer.scheduledTimer(timeInterval: 1, target: triviaManager, selector: #selector(TriviaManager.tick), userInfo: nil, repeats: true)
    }
    
    func designQuestionLabel(){
        questionLabel.layer.masksToBounds = true
        questionLabel.layer.cornerRadius = 17.39
//        progressLabel.textColor = UIColor(red: 69/225, green: 84/255, blue: 127/225, alpha: 1)
    }
    
    func buildShadow(for button: UIButton){
        button.layer.shadowColor = UIColor(red: 32/255, green: 101/255, blue: 125/255, alpha: 0.2).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 0.5
        button.layer.masksToBounds = false
    }

    @IBAction func selectOneOption(_ sender: UIButton) {
        
        guard !triviaManager.answerSelected else { return }
        
        let correctAnswer: AttributedString
        let titleLabel: AttributedString
        do {
            correctAnswer = try AttributedString(markdown: triviaManager.correctAnswer)
            titleLabel = try AttributedString(markdown:sender.titleLabel?.text ?? "")
        }
        catch{
            print("Error setting formattedQuestion: \(error)")
            return
        }
        
        if correctAnswer == titleLabel {
            sender.backgroundColor = UIColor(red: 170/225, green: 229/255, blue: 250/255, alpha: 1)
            triviaManager.score = triviaManager.score + 1
        }
        else
        {
            sender.backgroundColor = UIColor(red: 1, green: 73/255, blue: 92/255, alpha: 1)
        }
        triviaManager.answerSelected = true
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1){
            self.triviaManager.goToNextQuestion()
        }
    }
    
    func getOptionButtons(text: String) -> UIButton{
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .white
        btn.setTitle(text, for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(selectOneOption), for: .touchUpInside)
        buildShadow(for: btn)
        return btn
    }
}

extension ViewController: QuestionsManagerDelegate {

    func didUpdateQuestion(question: AttributedString, answers: [Answer], index: Int,length: Int) {
        // buid buttons
        DispatchQueue.main.async {
            self.buttonsContainer.removeAllArrangedSubviews()
            for answer in answers {
                let btn = self.getOptionButtons(
                    text: NSAttributedString(answer.text).string
                )
                self.buttonsContainer.addArrangedSubview(btn)
            }
            
            self.questionLabel.attributedText = NSAttributedString(question)
            self.progressLabel.text = "\(index+1)/\(length)"
        }
    }

    func didFailWithError(error: Error) {
        print(error)
    }
    
    func changeTime(time: Int) {
        timeLabel.text = "\(time)"
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "EndGameVC"){
                let displayVC = segue.destination as! EndGameViewController
            displayVC.score = triviaManager.score
        }
    }
    
    func endGame(score: Int) {
        self.performSegue(withIdentifier: "EndGameVC", sender: self)
        
    }
}

