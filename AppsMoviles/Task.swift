//
//  Task.swift
//  AppsMoviles
//
//  Created by Andrés De Lago Gómez on 02/10/17.
//
//

import Foundation

class Task{
    
    var deadline: Date
    var name: String
    var priority: Int
    var description: String
    var prerequisites: [Task]
    var place: String
    
    var recurrent: Bool
    var recurrentStart: Date
    var recurrentEnd: Date
    var recurrentDays: [String]
}
