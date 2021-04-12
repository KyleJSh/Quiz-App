//
//  StateManager.swift
//  Quiz App Practice
//
//  Created by Kyle Sherrington on 2021-04-07.
//

import Foundation

class StateManager {
    
    // keep track of correctly answered questions and where the user is in the question index

    static var numCorrectKey = "NumberCorrectKey"
    static var questionIndexKey = "QuestionIndexKey"
    
    static func saveState(numCorrect:Int, questionIndex:Int) {
        
        // get reference to user defaults
        let defaults = UserDefaults.standard
        
        defaults.set(numCorrect, forKey: numCorrectKey)
        defaults.set(questionIndex, forKey: questionIndexKey)
    }
    
    // defaults.value must return an optional Any value
    static func retrieveValue(key:String) -> Any? {
        
        // get reference to userdefaults
        let defaults = UserDefaults.standard
        
        return defaults.value(forKey: key)
        
    }
    
    static func clearState() {
        
        // get reference to user defaults
        let defaults = UserDefaults.standard
        
        // clear state data in user defaults
        defaults.removeObject(forKey: numCorrectKey)
        defaults.removeObject(forKey: questionIndexKey)
        
    }
    
}
