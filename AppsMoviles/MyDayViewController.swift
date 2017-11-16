//
//  MyDayViewController.swift
//  AppsMoviles
//
//  Created by Andrés De Lago Gómez on 14/09/17.
//
//

import UIKit
import UserNotifications

class MyDayViewController: UIViewController, RATreeViewDelegate, RATreeViewDataSource {

    var todayTasks = [Task]()
    var tasks : RATreeView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTree()
    }
    
    @IBAction func AddButtonClick(_ sender: Any) {
        let popUpVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "newTaskPopUp") as! NewTaskVC
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge],  completionHandler: {didAllow, error in})
        
        tasks = RATreeView(frame: CGRect(x: 0, y: 80, width: self.view.frame.width, height: self.view.frame.height * 0.8))
        tasks.register(UINib(nibName: String(describing: TreeTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TreeTableViewCell.self))
        tasks.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        tasks.dataSource = self
        tasks.delegate = self
        tasks.treeFooterView = UIView()
        tasks.backgroundColor = .clear
        view.addSubview(tasks)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tabBarItem.image = UIImage.fontAwesomeIcon(name: .calendarCheckO, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        tabBarItem.selectedImage = tabBarItem.image
    }
    
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {
        return todayTasks.count
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        let cell = treeView.dequeueReusableCell(withIdentifier: String(describing: TreeTableViewCell.self)) as! TreeTableViewCell
        let item = item as! Task
        let level = 0
        cell.setup(withTitle: item.name, detailsText: item.description, level: level, additionalButtonHidden: true)
        if (item.finished == true){
            print(item.name)
            cell.done()
        }
        return cell
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {
        return todayTasks[index]
    }

    func returnTodayTasks(tasks: [Task])->[Task]{
        var todayTasks = [Task]()
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "es_MX") as Locale!
        formatter.timeStyle = DateFormatter.Style.none
        formatter.dateFormat = "DD.MM.YYYY"
        
        let date = formatter.string(from: Date())
        for task in tasks{
            if (formatter.string(from: task.deadline) == date){
                todayTasks.append(task)
            }
            if (task.recurrent == true){
                formatter.dateStyle = DateFormatter.Style.full
                if (Date() > task.recurrentStart && Date() < task.recurrentEnd){
                    for day in task.recurrentDays{
                        if (formatter.string(from: Date()).dropLast(25).contains(day)){
                            todayTasks.append(task)
                        }
                    }
                }
            }
        }
        return todayTasks
        //PRUEBAS DATE FORMATTER
        /* let lmao = formatter.string(from: Date())
         print(lmao)
         if (Date() < Date(timeInterval: 100000000, since: Date())){
         print ("sicierto")
         }
         print(lmao.dropLast(25))
         for day in formatter.shortWeekdaySymbols{
         if (lmao.dropLast(25).contains(day)){
         print(day)
         }
         }*/
    }
    
    func reloadTree(){
        todayTasks = returnTodayTasks(tasks: Store.getTasks())
        tasks.reloadData()
    }
    
    func treeView(_ treeView: RATreeView, editActionsForItem item: Any) -> [Any] {
        let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Editar", handler:{action, indexpath in
            let task = item as? Task
            let popUpVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "newTaskPopUp") as! NewTaskVC
            popUpVC.editTask = task
            self.addChildViewController(popUpVC)
            popUpVC.view.frame = self.view.frame
            self.view.addSubview(popUpVC.view)
            popUpVC.didMove(toParentViewController: self)
            self.tasks.reloadRows()
        });
        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            var index: Int = 0
            let task = item as? Task
            index = (self.todayTasks.index(where: {Task in
                return Task === task
            }))!
            print(index)
            Store.deleteTask(task!)
            self.todayTasks.remove(at: index)
            self.tasks.deleteItems(at: IndexSet(integer: index), inParent: nil, with: RATreeViewRowAnimation.init(1))
        });
        
        let doneRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Hecho", handler:{action, indexpath in
            let item = item as! Task
            let cell = treeView.cell(forItem: item) as! TreeTableViewCell
            cell.done()
            item.finished = true
            Store.saveTask(item, Goal())
            self.tasks.reloadData()
        });
        doneRowAction.backgroundColor = UIColor.lightGray
        
        return [deleteRowAction, moreRowAction, doneRowAction];
    }

 
    func treeView(_ treeView: RATreeView, shouldExpandRowForItem item: Any) -> Bool {
        return false
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
