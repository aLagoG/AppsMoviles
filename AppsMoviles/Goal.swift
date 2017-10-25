//
//  Goal.swift
//  AppsMoviles
//
//  Created by Andrés De Lago Gómez on 02/10/17.
//
//

import Foundation

class Goal{
    
    var deadline: Date = Date.init()
    var startDate: Date = Date.init()
    var name: String = ""
    var priority: Int = 0
    var description: String = ""
    var color: UIColor = UIColor.clear
    var tasks: [Task] = []
    var tasksDone: Int = 0
    
    init(deadline: Date, startDate: Date,name: String, priority: Int, description: String, color: UIColor, tasks: [Task]){
        self.deadline = deadline
        self.startDate = startDate
        self.name = name
        self.priority = priority
        self.description = description
        self.color = color
        self.tasks = tasks
        self.tasksDone = 0
    }
    
    func countTasksDone()->Int{
        for task in tasks {
            if task.finished == true {
                tasksDone = tasksDone + 1
            }
        }
        return tasksDone
    }
    
    func addTask(_ task : Task) {
        self.tasks.append(task)
    }
    
    func removeTask(_ task : Task) {
        self.tasks = self.tasks.filter( {$0 !== task})
    }
}


