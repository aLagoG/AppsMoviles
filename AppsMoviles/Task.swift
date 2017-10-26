//
//  Task.swift
//  AppsMoviles
//
//  Created by Andrés De Lago Gómez on 02/10/17.
//
//

import Foundation

class Task{
    
    var id: Int64 = 0
    var deadline: Date = Date.init()
    var name: String = ""
    var priority: Int64 = 0
    var description: String = ""
    var place: String = ""
    var finished : Bool = false
    
    var recurrent: Bool = false
    var recurrentStart: Date = Date.init()
    var recurrentEnd: Date = Date.init()
    var recurrentDays: [String] = []
    
    init(){

    }
    
    init(deadline: Date, name: String, priority: Int64, description: String, place: String, recurrent: Bool){
        self.deadline = deadline
        self.name = name
        self.priority = priority
        self.description = description
        self.place = place
    }
    
    init(deadline: Date, name: String, priority: Int64, description: String, place: String, recurrent: Bool, recurrentStart: Date, recurrentEnd: Date, recurrentDays:[String]){
        self.deadline = deadline
        self.name = name
        self.priority = priority
        self.description = description
        self.place = place
    }
}
