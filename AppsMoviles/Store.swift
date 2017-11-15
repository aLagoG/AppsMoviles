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
        print("Connecting to db")
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            db = try Connection("\(path)/db.sqlite3")
        } catch  {
            print("Error with db connection")
        }
    }
    
    static func initDB(){
        initConnection()
        print("Creating tables")
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
        } catch  {
            print("Error creating goals table")
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
        } catch  {
            print("Error creating tasks table")
        }
        
        do {
            try db?.run(recurrentDays.create { t in
                t.column(task_id)
                t.column(day)
                t.foreignKey(task_id, references: tasks, id)
                t.primaryKey(task_id, day)
            })
        } catch  {
            print("Error creating recurrentDays table")
        }
    }
    static func saveGoal(_ goal: Goal){
        if(goal.id == 0){
            do {
                let gid = try db?.run(goals.insert(deadline <- goal.deadline, startDate <- goal.startDate, name <- goal.name, priority <- goal.priority, description <- goal.description, color <- colorToRGB(goal.color)))
                goal.id = gid!
            }catch  {
                print("Error creating goal")
            }
        }else{
            do {
                let toEdit = goals.filter(id == goal.id)
                try db?.run(toEdit.update(deadline <- goal.deadline, startDate <- goal.startDate, name <- goal.name, priority <- goal.priority, description <- goal.description, color <- colorToRGB(goal.color)))
            } catch {
                print("Error updating goal: \(error)")
            }
        }
    }
    
    // should probably run all these on a db.transaction
    static func saveTask(_ task: Task, _ goal: Goal){
        if(task.id == 0){
            do {
                let tid = try db?.run(tasks.insert(deadline <- task.deadline, name <- task.name, priority <- task.priority, description <- task.description, place <- task.place, recurrent <- task.recurrent, recurrentStart <- task.recurrentStart, recurrentEnd <- task.recurrentEnd, goal_id <- goal.id))
                task.id = tid!
                if(task.recurrentDays.count > 0){
                    for d in task.recurrentDays{
                        do{
                            try db?.run(recurrentDays.insert( task_id <- task.id, day <- d))
                        } catch  {
                            print("Error inserting day: \(error)")
                        }
                    }
                }
            } catch {
                print("Error creating task: \(error)")
            }
        } else {
            do {
                let toEdit = tasks.filter(id == task.id)
                try db?.run(toEdit.update(deadline <- task.deadline, name <- task.name, priority <- task.priority, description <- task.description, place <- task.place, recurrent <- task.recurrent, recurrentStart <- task.recurrentStart, recurrentEnd <- task.recurrentEnd))
                let currentDays = recurrentDays.filter(task_id == task.id)
                do {
                    try db?.run(currentDays.delete())
                } catch {
                    print("Error deleting days: \(error)")
                }
                if(task.recurrentDays.count > 0){
                    for d in task.recurrentDays{
                        do{
                            try db?.run(recurrentDays.insert( task_id <- task.id, day <- d))
                        } catch  {
                            print("Error inserting day: \(error)")
                        }
                    }
                }
            } catch {
                print("Error updating task: \(error)")
            }
        }
    }
    
    static func getGoals()-> [Goal]{
        var result: [Goal] = []
        do {
            let res = try db?.prepare(goals)
            if let rows = res {
                for row in rows{
                    let goal: Goal = Goal()
                    goal.id  = row[id]
                    goal.deadline  = row[deadline]
                    goal.startDate  = row[startDate]
                    goal.name  = row[name]
                    goal.priority  = row[priority]
                    goal.description  = row[description]
                    goal.color  = colorFromRGB(row[color])
                    goal.tasks = getTasks(goal)
                    result.append(goal)
                }
            }
        } catch {
            print("Error getting goals")
        }
        return result
    }
    
    static func getTasks( _ goal: Goal) -> [Task]{
        var result : [Task] = []
        do {
            let res = try db?.prepare(tasks.filter(goal_id == goal.id))
            if let rows = res {
                for row in rows{
                    let task: Task = Task()
                    task.id = row[id]
                    task.deadline = row[deadline]
                    task.name = row[name]
                    task.priority = row[priority]
                    task.description = row[description]
                    task.place = row[place]
                    task.recurrent = row[recurrent]
                    task.recurrentStart = row[recurrentStart]
                    task.recurrentEnd = row[recurrentEnd]
                    result.append(task)
                    for dy in (try db?.prepare(recurrentDays.filter(task_id == task.id)))!{
                        task.recurrentDays.append(dy[day])
                    }
                }
            }
        } catch  {
            print("Error getting tasks from goal: \(goal.name)")
        }
        return result
    }
    
    static func getTasks() -> [Task]{
        var result : [Task] = []
        do {
            let res = try db?.prepare(tasks)
            if let rows = res{
                for row in rows{
                    let task: Task = Task()
                    task.id = row[id]
                    task.deadline = row[deadline]
                    task.name = row[name]
                    task.priority = row[priority]
                    task.description = row[description]
                    task.place = row[place]
                    task.recurrent = row[recurrent]
                    task.recurrentStart = row[recurrentStart]
                    task.recurrentEnd = row[recurrentEnd]
                    result.append(task)
                    for dy in (try db?.prepare(recurrentDays.filter(task_id == task.id)))!{
                        task.recurrentDays.append(dy[day])
                    }
                }
            }
        } catch  {
            
        }
        return result
    }
    
    static func deleteTask(_ task: Task){
        do{
            let deletedItem = tasks.filter(id == task.id)
            try db?.run(deletedItem.delete())
        }catch {
        }
    }
    
    static func deleteGoal(_ goal: Goal){
        do{
            let deletedItem = goals.filter(id == goal.id)
            try db?.run(deletedItem.delete())
        }catch {
        }
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
    
    static func createTestRecords(){
        print("Creating test records")
        let T1 = Task(deadline: Date.init(), name: "T1", priority: 1, description: "T1 des",place: "T1 P", recurrent: false)
        let T2 = Task(deadline: Date.init(), name: "T2", priority: 1, description: "T2 des", place: "T2 P", recurrent: false)
        let T3 = Task(deadline: Date.init(), name: "T3", priority: 1, description: "T3 des", place: "T3 P", recurrent: false)
        let T4 = Task(deadline: Date.init(), name: "T4", priority: 1, description: "T4 des", place: "T4 P", recurrent: false)
        let T5 = Task(deadline: Date.init(), name: "T5", priority: 1, description: "T5 des", place: "T5 P", recurrent: false)
        let T6 = Task(deadline: Date.init(), name: "T6", priority: 1, description: "T6 des", place: "T6 P", recurrent: false)
        
        let g1 = Goal(deadline: Date.init(), startDate: Date.init(),name: "G1", priority: 1, description: "G1 as", color: UIColor.blue, tasks:[T1, T2])
        let g2 = Goal(deadline: Date.init(), startDate: Date.init(),name: "G2", priority: 2, description: "G2 as", color: UIColor.black,tasks:[T3])
        let g3 = Goal(deadline: Date.init(), startDate: Date.init(),name: "G3", priority: 3, description: "G3 as", color: UIColor.brown,tasks:[T4, T5])
        let g4 = Goal(deadline: Date.init(), startDate: Date.init(),name: "G4", priority: 4, description: "G4 as", color: UIColor.blue,tasks:[])
        let g5 = Goal(deadline: Date.init(), startDate: Date.init(),name: "G5", priority: 5, description: "G5 as", color: UIColor.blue,tasks:[T6])
        
        saveGoal(g1)
        saveGoal(g2)
        saveGoal(g3)
        saveGoal(g4)
        saveGoal(g5)
        saveTask(T1,g1)
        saveTask(T2,g1)
        saveTask(T3,g2)
        saveTask(T4,g3)
        saveTask(T5,g3)
        saveTask(T6,g5)
    }
    
}
