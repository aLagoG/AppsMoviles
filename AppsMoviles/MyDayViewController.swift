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
    var taskTree : RATreeView!

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
        
        taskTree = RATreeView(frame: CGRect(x: 0, y: 80, width: self.view.frame.width, height: self.view.frame.height - 100))
        taskTree.register(UINib(nibName: String(describing: TreeTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TreeTableViewCell.self))
        taskTree.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        taskTree.dataSource = self
        taskTree.delegate = self
        taskTree.treeFooterView = UIView()
        taskTree.backgroundColor = .clear
        view.addSubview(taskTree)

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
            cell.done()
        }
        return cell
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {
        return todayTasks[index]
    }

    func returnTodayTasks(taskTree: [Task])->[Task]{
        var tdTasks = [Task]()
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "es_MX") as Locale!
        formatter.timeStyle = DateFormatter.Style.none
        formatter.dateStyle = DateFormatter.Style.full
        let today = Date()
        let date = formatter.string(from: today)
        for task in taskTree{
            if formatter.string(from: task.deadline) == date{
                tdTasks.append(task)
            } else if task.recurrent{
                if (today >= task.recurrentStart && today <= task.recurrentEnd){
                    if task.recurrentDays.contains(String(date.prefix(3))){
                        tdTasks.append(task)
                    }
                }
            }
        }
        return tdTasks
    }
    
    func reloadTree(){
        todayTasks = returnTodayTasks(taskTree: Store.getTasks())
        taskTree.reloadData()
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
            self.taskTree.reloadRows()
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
            self.taskTree.deleteItems(at: IndexSet(integer: index), inParent: nil, with: RATreeViewRowAnimation.init(1))
        });
        
        let doneRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Hecho", handler:{action, indexpath in
            let item = item as! Task
            let cell = treeView.cell(forItem: item) as! TreeTableViewCell
            cell.done()
            item.finished = true
            Store.saveTask(item, Goal())
            self.taskTree.reloadData()
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
