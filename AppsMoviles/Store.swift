//
//  Store.swift
//  AppsMoviles
//
//  Created by Andrés De Lago Gómez on 23/10/17.
//

import Foundation
import SQLite

class Store{
    static var db:Connection? = nil
    
    static let goals = Table("goals")
    static let id = Expression<Int64>("id")
    static let deadline = Expression<Date>("deadline")
    static let startDate = Expression<Date>("startDate")
    static let name = Expression<String>("name")
    static let priority = Expression<Int64>("priority")
    static let description = Expression<String>("description")
    static let color = Expression<Int64>("color")
    
    static let tasks = Table("tasks")
    static let goal_id = Expression<Int64>("goal_id")
    static let place = Expression<String>("place")
    static let recurrent = Expression<Bool>("recurrent")
    static let recurrentStart = Expression<Date>("recurrentStart")
    static let recurrentEnd = Expression<Date>("recurrentEnd")
    
    static let recurrentDays = Table("recurrent_days")
    static let task_id = Expression<Int64>("task_id")
    static let day = Expression<String>("day")
    
    static func initConnection(){
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            db = try Connection("\(path)/db.sqlite3")
        } catch _ {
            //dont know what to do
        }
    }
    
    static func initDB(){
        initConnection()
    
        do {
            try db?.run(goals.create { t in
                t.column(id, primaryKey: .autoincrement) //either that or true
                t.column(deadline)
                t.column(startDate)
                t.column(name)
                t.column(priority)
                t.column(description)
                t.column(color)
            })
        } catch _ {
            //dont know what to do
        }
        
        do {
            try db?.run(tasks.create { t in
                t.column(id, primaryKey: .autoincrement) //either that or true
                t.column(deadline)
                t.column(name)
                t.column(priority)
                t.column(description)
                t.column(place)
                t.column(recurrent)
                t.column(recurrentStart)
                t.column(recurrentEnd)
                t.column(goal_id)
                t.foreignKey(goal_id, references: goals, id)
            })
        } catch _ {
            //dont know what to do
        }
        
        do {
            try db?.run(recurrentDays.create { t in
                t.column(task_id)
                t.column(day)
                t.foreignKey(task_id, references: tasks, id)
                t.primaryKey(task_id, day)
            })
        } catch _ {
            //dont know what to do
        }
    }
    static func saveGoal(_ goal: Goal){
        if(goal.id == 0){
            do {
                let gid = try db?.run(goals.insert(deadline <- goal.deadline, startDate <- goal.startDate, name <- goal.name, priority <- goal.priority, description <- goal.description, color <- colorToRGB(goal.color)))
                goal.id = gid!
            }catch _ {
                
            }
        }else{
            do {
                try db?.run(goals.update(id <- goal.id, deadline <- goal.deadline, startDate <- goal.startDate, name <- goal.name, priority <- goal.priority, description <- goal.description, color <- colorToRGB(goal.color)))
            } catch _{
                
            }
        }
    }
    
    // should probably run all these on a db.transaction
    static func saveTask(_ task: Task, _ goal: Goal) -> Bool{
        if(task.id == 0){
            do {
                let tid = try db?.run(tasks.insert(deadline <- task.deadline, name <- task.name, priority <- task.priority, description <- task.description, place <- task.place, recurrent <- task.recurrent, recurrentStart <- task.recurrentStart, recurrentEnd <- task.recurrentEnd, goal_id <- goal.id))
                task.id = tid!
                if(task.recurrentDays.count > 0){
                    for d in task.recurrentDays{
                        do{
                            try db?.run(recurrentDays.insert( task_id <- task.id, day <- d))
                        } catch _ {
                            
                        }
                    }
                }
                return true
            } catch _{
                return false
            }
        } else {
            do {
                try db?.run(tasks.update(id <- task.id, deadline <- task.deadline, name <- task.name, priority <- task.priority, description <- task.description, place <- task.place, recurrent <- task.recurrent, recurrentStart <- task.recurrentStart, recurrentEnd <- task.recurrentEnd, goal_id <- goal.id))
                let currentDays = recurrentDays.filter(task_id == task.id)
                do {
                    try db?.run(currentDays.delete())
                } catch _{
                    
                }
                if(task.recurrentDays.count > 0){
                    for d in task.recurrentDays{
                        do{
                            try db?.run(recurrentDays.insert( task_id <- task.id, day <- d))
                        } catch _ {
                            
                        }
                    }
                }
                return true
            } catch _{
                return false
            }
        }
    }
    
    static func getGoals()-> [Goal]{
        var result: [Goal] = []
        do {
            for row in (try db?.prepare(goals))!{
                let goal: Goal = Goal()
                goal.id  = row[id]
                goal.deadline  = row[deadline]
                goal.startDate  = row[startDate]
                goal.name  = row[name]
                goal.priority  = row[priority]
                goal.description  = row[description]
                goal.color  = colorFromRGB(row[color])
                result.append(goal)
            }
        } catch {
            
        }
        return result
    }
    
    static func colorFromRGB(_ rgb: Int64) -> UIColor{
        return UIColor(red: CGFloat(((rgb & 0xFF000000)>>24)/255), green: CGFloat(((rgb & 0x00FF0000)>>16)/255), blue: CGFloat(((rgb & 0x0000FF00)>>8)/255), alpha: CGFloat((rgb & 0x000000FF)/255))
    }
    
    static func colorToRGB(_ color: UIColor) -> Int64{
        var result: Int64 = 0
        let values = color.cgColor.components!
        if(values.count == 2){
            let cl: Int64 = Int64(values[0] * 255)
            let a: Int64 = Int64(values[1]*255)
            result = (cl << 24) | (cl << 16) | (cl << 8) | a
        }else if(values.count == 4){
            let r: Int64 = Int64(values[0] * 255)
            let g: Int64 = Int64(values[1] * 255)
            let b: Int64 = Int64(values[2] * 255)
            let a: Int64 = Int64(values[3] * 255)
            result = (r << 24) | (g << 16) | (b << 8) | a
        }
        return result
    }
    
}
