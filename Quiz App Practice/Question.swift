//
//  Question.swift
//  Quiz App Practice
//
//  Created by Kyle Sherrington on 2021-04-06.
//

import Foundation

struct Question: Codable {
    
    var question:String?
    var answers:[String]?
    var correctAnswerIndex:Int?
    var feedback:String?
    
}
