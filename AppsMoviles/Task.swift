//
//  Task.swift
//  AppsMoviles
//
//  Created by Andrés De Lago Gómez on 02/10/17.
//
//

import Foundation

class Task{
    
    var deadline: Date = Date.init()
    var name: String = ""
    var priority: Int = 0
    var description: String = ""
    var prerequisites: [Task] = []
    var place: String = ""
    var finished : Bool = false
    
    var recurrent: Bool = false
    var recurrentStart: Date = Date.init()
    var recurrentEnd: Date = Date.init()
    var recurrentDays: [String] = []
    
    init(deadline: Date, name: String, priority: Int, description: String, prerequisites:[Task], place: String){
        self.deadline = deadline
        self.name = name
        self.priority = priority
        self.description = description
        self.prerequisites = prerequisites
        self.place = place
    }
}
