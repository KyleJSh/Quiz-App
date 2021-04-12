//
//  ViewController.swift
//  Quiz App Practice
//
//  Created by Kyle Sherrington on 2021-04-06.
//

import UIKit

class ViewController: UIViewController, QuizProtocol, UITableViewDelegate, UITableViewDataSource, ResultViewControllerProtocol {
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var rootStackView: UIStackView!
    
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewTrailingConstraint: NSLayoutConstraint!
    
    var model = QuizModel()
    var questions = [Question]()
    var currentQuestionIndex = 0
    var numCorrect = 0
    
    var resultDialog:ResultViewController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the result dialog
        resultDialog = storyboard?.instantiateViewController(identifier: "ResultVC") as? ResultViewController
        resultDialog?.modalPresentationStyle = .overCurrentContext
        resultDialog?.delegate = self
        
        // Set self as the delegate and datasource for the tableview
        tableView.delegate = self
        tableView.dataSource = self
        
        // Dynamic row heights
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        // Set up the model
        model.delegate = self
        model.getQuestions()
    }
    
    // MARK: Methods
    
    func slideInQuestion() {
        
        // set initial state, this is off screen
        stackViewLeadingConstraint.constant = 1000
        stackViewTrailingConstraint.constant = -1000
        rootStackView.alpha = 0
        
        // tell layout system to update all elements based on constraints
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            
            // set initial state, this is off screen
            self.stackViewLeadingConstraint.constant = 0
            self.stackViewTrailingConstraint.constant = 0
            self.rootStackView.alpha = 1
            
            // tell layout system to update all elements based on constraints
            self.view.layoutIfNeeded()
            
            
        }, completion: nil)
        
    }
    
    func slideOutQuestion() {
        
        // set initial state
        stackViewLeadingConstraint.constant = 0
        stackViewTrailingConstraint.constant = 0
        rootStackView.alpha = 1
        
        // tell layout system to update all elements based on constraints
        view.layoutIfNeeded()
        
        // animate to the end state
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            
            self.stackViewLeadingConstraint.constant = -1000
            self.stackViewTrailingConstraint.constant = 1000
            self.rootStackView.alpha = 0
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    
    func displayQuestion() {
        
        // Check if there are questions and check that the currentQuestionIndex is not out of bounds
        guard questions.count > 0 && currentQuestionIndex < questions.count else {
            return
        }
        
        // Display the question text
        questionLabel.text = questions[currentQuestionIndex].question
        
        // Reload the answers table
        tableView.reloadData()
        
        // animate the question to slide in from the right
        slideInQuestion()
        
    }
    
    func questionsRetrieved(_ questions: [Question]) {
        
        // Get a reference to the questions
        self.questions = questions
        
        // check if we should restore the state before displaying the first question
        let savedIndex = StateManager.retrieveValue(key: StateManager.questionIndexKey) as? Int
        
        // is there a saved index?, if not nil, force unwrap, is it within the bounds of the question we have
        if savedIndex != nil && savedIndex! < self.questions.count {
            
            // set the current question to the saved index
            currentQuestionIndex = savedIndex!
            
            // retrieve the number correct from storage, force unwrap, if this is nil, can crash app
            let savedNumCorrect = StateManager.retrieveValue(key: StateManager.numCorrectKey) as? Int
            
            if savedNumCorrect != nil {
                
                numCorrect = savedNumCorrect!
                
            }
            
        }
        
        // Display the first question
        displayQuestion()
    }

    // MARK: - UITableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Make sure that the questions array actually contains at least a question
        guard questions.count > 0 else {
            return 0
        }
        
        // Return the number of answers for this question
        let currentQuestion = questions[currentQuestionIndex]
        
        if currentQuestion.answers != nil {
            return currentQuestion.answers!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
        
        // Customize it
        let label = cell.viewWithTag(1) as? UILabel
        
        if label != nil {
            
            let question = questions[currentQuestionIndex]
            
            if question.answers != nil && indexPath.row < question.answers!.count {
                // Set the answer text for the label
                label!.text = question.answers![indexPath.row]
            }
        }
        
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var titleText = ""
        
        DispatchQueue.main.async {
            
            // upon selection, slide the question out on the main thread, as we're updating the UI
            self.slideOutQuestion()
            
        }
        
        // User has tapped on a row, check if it's the right answer
        let question = questions[currentQuestionIndex]
        
        if question.correctAnswerIndex! == indexPath.row {
            
            // User got it right
            print("User got it right")
            
            // update the titleText and increment the numCorrect
            titleText = "Correct!"
            numCorrect += 1
        }
        else {
            // User got it wrong
            print("User got it wrong")
            titleText = "Wrong!"
        }
        
        // Show the popup
        if resultDialog != nil {
            
            // customize the dialog text
            resultDialog!.titleText = titleText
            resultDialog!.feedbackText = question.feedback!
            resultDialog!.buttonText = "Next"
            
            // present popup on the main thread
            DispatchQueue.main.async {
                
                self.present(self.resultDialog!, animated: true, completion: nil)
                
            }
        }
        
    }
    
   // MARK: - Result View Controller Protocol
    
    func dialogDismissed() {
                
        // Increment the currentQuestionIndex
        currentQuestionIndex += 1
        
        // check if there's another question in array before displaying the next question, can crash otherwise
        if currentQuestionIndex == questions.count {
            
            // user is on the last question, display a summary dialog
            // Show the popup
            if resultDialog != nil {
                
                // display summary dialog
                resultDialog!.titleText = "Summary"
                // show user their final results with numCorrect
                resultDialog!.feedbackText = "You got \(numCorrect) correct out of \(questions.count) questions"
                // last questions, allow for restart of questions
                resultDialog!.buttonText = "Restart"
                
                // present popup
                present(resultDialog!, animated: true, completion: nil)
                
                StateManager.clearState()
            }
            
        }
        else if currentQuestionIndex > questions.count {
            
            // restart the questions
            numCorrect = 0
            currentQuestionIndex = 0
            displayQuestion()
            
        }
        else if currentQuestionIndex < questions.count {
            
            // there are more questions to display
            displayQuestion()
            
            // save state
            StateManager.saveState(numCorrect: numCorrect, questionIndex: currentQuestionIndex)
            
        }
        
  
    }
    
    
}
