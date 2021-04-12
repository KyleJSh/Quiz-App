//
//  QuizModel.swift
//  Quiz App Practice
//
//  Created by Kyle Sherrington on 2021-04-06.
//

import Foundation

protocol QuizProtocol {
    
    func questionsRetrieved(_ questions:[Question])
    
}

class QuizModel {
    
    var delegate:QuizProtocol?
    
    func getQuestions() {
        
       getRemoteJsonFile()
        
    }
    
    func getLocalJsonFile() {
        
        // get path/string to local JSON file
        let path = Bundle.main.path(forResource: "QuestionData", ofType: "json")
        
        // check for nil
        guard path != nil else {
            // couldn't get path to local JSON
            return
        }
        
        let url = URL(fileURLWithPath: path!)
        
        do {
            
            // try to get data from URL
            let data = try Data(contentsOf: url)
            
            // create JSONDecoder instance
            let decoder = JSONDecoder()
            
            // try to decode the data into objects
            let array = try decoder.decode([Question].self, from: data)

            // notify the delegate of the parsed JSON data
            delegate?.questionsRetrieved(array)
            
        }
        catch {
            print("Couldn't retrieve data from local JSON")
        }  
        
    }
    
    func getRemoteJsonFile() {
        
        // get a URL object
        let urlString = "https://codewithchris.com/code/QuestionData.json"
        let url = URL(string: urlString)
        
        // check for hil
        guard url != nil else {
            print("Couldn't create url object")
            return
        }
        
        // get a URL session object
        let session = URLSession.shared
        
        // get a datatask
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            
            if error == nil && data != nil {
                
                do {
                    
                    // create json decoder object
                    let decoder = JSONDecoder()
                    
                    // parse json
                    let array = try decoder.decode([Question].self, from: data!)
                    
                    // return the array on the main thread
                    DispatchQueue.main.async {
                        
                        // notify the delegate
                        self.delegate?.questionsRetrieved(array)
                        
                    }
                    
                }
                catch {
                    
                }
                
            } // end if statement
            
        }
        // call resume on the datatask
        dataTask.resume()
        
    }
}

