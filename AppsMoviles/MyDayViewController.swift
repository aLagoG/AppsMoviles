//
//  MyDayViewController.swift
//  AppsMoviles
//
//  Created by Héctor Iván Aguirre Arteaga on 14/11/17.
//

import UIKit

class MyDayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tasks:[Task] = Store.getTasks()
    var todayTasks:[Task] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem.image = UIImage.fontAwesomeIcon(name: .calendarO, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        tabBarItem.selectedImage = tabBarItem.image
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! MyDayTableViewCell
        cell.nameL.text = todayTasks[indexPath.row].name
        cell.desL.text = todayTasks[indexPath.row].description
        cell.placeL.text = todayTasks[indexPath.row].place
        cell.priorV.tintColor = UIColor.blue
        
        return cell
        
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = Store.getTasks()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let date = formatter.string(from: Date())
        for task in tasks{
            if formatter.string(from: task.deadline) == date {
                todayTasks.append(task)
                print(task.name)
                print(formatter.string(from: task.deadline))
            }
        }
        // Do any additional setup after loading the view.
        //print("Las actividades de hoy")
        //print(todayTasks)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
