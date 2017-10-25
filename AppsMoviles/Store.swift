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
    
    static func initConnection(){
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            Store.db = try Connection("\(path)/db.sqlite3")
        } catch _ {
            //dont know what to do
        }
    }
    
    static func initDB(){
        Store.initConnection()
        
        let goals = Table("goals")
        let id = Expression<Int>("id")
        let deadline = Expression<Date>("deadline")
        let startDate = Expression<Date>("startDate")
        let name = Expression<String>("name")
        let priority = Expression<Int>("priority")
        let description = Expression<String>("description")
        let color = Expression<Int64>("color")
        
        do {
            try Store.db?.run(goals.create { t in
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
        
        let tasks = Table("tasks")
        let goal_id = Expression<Int>("goal_id")
        let place = Expression<String>("place")
        let recurrent = Expression<Bool>("recurrent")
        let recurrentStart = Expression<Date>("recurrentStart")
        let recurrentEnd = Expression<Date>("recurrentEnd")
        
        do {
            try Store.db?.run(tasks.create { t in
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
        
        let recurrentDays = Table("recurrent_days")
        let task_id = Expression<Int>("task_id")
        let day = Expression<String>("day")
        
        do {
            try Store.db?.run(recurrentDays.create { t in
                t.column(task_id)
                t.column(day)
                t.foreignKey(task_id, references: tasks, id)
                t.primaryKey(task_id, day)
            })
        } catch _ {
            //dont know what to do
        }
        
        let prerequisites = Table("prerequisites")
        let req_id = Expression<Int>("req_id")
        do {
            try Store.db?.run(prerequisites.create { t in
                t.column(task_id)
                t.column(req_id)
                t.foreignKey(task_id, references: tasks, id)
                t.foreignKey(req_id, references: tasks, id)
                t.primaryKey(task_id, req_id)
            })
        } catch _ {
            //dont know what to do
        }
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
