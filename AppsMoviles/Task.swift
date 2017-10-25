//
//  Task.swift
//  AppsMoviles
//
//  Created by Andrés De Lago Gómez on 02/10/17.
//
//

import Foundation

class Task{
    
    var id: Int = 0
    var deadline: Date = Date.init()
    var name: String = ""
    var priority: Int = 0
    var description: String = ""
    var prerequisites: [Task] = []
    var place: String = ""
    
    var recurrent: Bool = false
    var recurrentStart: Date = Date.init()
    var recurrentEnd: Date = Date.init()
    var recurrentDays: [String] = []
}
