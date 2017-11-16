//
//  GoalsViewController.swift
//  AppsMoviles
//
//  Created by Andrés De Lago Gómez on 14/09/17.
//
//

import UIKit
import RATreeView

class GoalsViewController: UIViewController, RATreeViewDelegate, RATreeViewDataSource {

    var goalLst=[Goal]()
    var goals : RATreeView!
    var expansions: [Int64: Bool] = [Int64: Bool]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTree()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goals = RATreeView(frame: CGRect(x: 0 , y: 80, width: self.view.frame.width, height: self.view.frame.height * 0.7))
        goals.register(UINib(nibName: String(describing: TreeTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TreeTableViewCell.self))
        goals.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        goals.dataSource = self
        goals.delegate = self
        goals.treeFooterView = UIView()
        goals.backgroundColor = .clear
        view.addSubview(goals)
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tabBarItem.image = UIImage.fontAwesomeIcon(name: .flagCheckered, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        tabBarItem.selectedImage = tabBarItem.image

    }

    
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {
        if let goal = item as? Goal{
            return goal.tasks.count
        } else{
            return self.goalLst.count
        }
    }
    
    //funcion para crear las celdas de la tabla con las metas y tareas
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        let cell = treeView.dequeueReusableCell(withIdentifier: String(describing: TreeTableViewCell.self)) as! TreeTableViewCell
        if let goal = item as? Goal{
            let doneTasks = goal.countTasksDone()
            let detailText = "Tareas hechas: \(doneTasks) de \(goal.tasks.count)"
            let level = 0
            cell.selectionStyle = .none
            cell.setup(withTitle: goal.name, detailsText: detailText, level: level, additionalButtonHidden: false)

            goal.isFinished()
            if (goal.finished == true){
                cell.done()
            }
        }else if let task = item as? Task{
            let detailText = task.description
            let level = 1
            cell.selectionStyle = .none
            cell.setup(withTitle: task.name, detailsText: detailText, level: level, additionalButtonHidden: true)
            if (task.finished == true){
                cell.done()
            }
        }

        cell.additionButtonActionBlock = { [weak treeView] cell in
            guard let treeView = treeView else {
                return;
            }
            let item = treeView.item(for: cell) as! Goal
            
            let popUpVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "newTaskPopUp") as! NewTaskVC
            self.addChildViewController(popUpVC)
            popUpVC.view.frame = self.view.frame
            self.view.addSubview(popUpVC.view)
            popUpVC.didMove(toParentViewController: self)
            popUpVC.goal = item
            
            
            /*item.addTask(newItem)
            treeView.insertItems(at: IndexSet(integer: item.tasks.count-1), inParent: item, with: RATreeViewRowAnimation.init(0))*/
            treeView.reloadRows(forItems: [item], with: RATreeViewRowAnimation.init(0))
        }
        
        
        return cell
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? Goal {
            return item.tasks[index]
        } else {
            return goalLst[index] as AnyObject
        }
    }
    
    func treeView(_ treeView: RATreeView, shouldExpandRowForItem item: Any) -> Bool {
        if treeView.levelForCell(forItem: item) == 0{
            return true
        }else{
            return false
        }
    }
    
    func treeView(_ treeView: RATreeView, didExpandRowForItem item: Any) {
        let goal = item as! Goal
        expansions[goal.id] = true
    }
    
    func treeView(_ treeView: RATreeView, didCollapseRowForItem item: Any) {
        let goal = item as! Goal
        expansions[goal.id] = nil
    }
    
    @IBAction func addGoalButtonClick(_ sender: Any) {
        let popUpVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "newGoalPopUp") as! NewGoalVC
        self.addChildViewController(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParentViewController: self)
    }
    
    func reloadTree(){
        goalLst = Store.getGoals()
        goals.reloadData()
        for goal in goalLst{
            if expansions[goal.id] != nil{
                goals.expandRow(forItem: goal)
            }
        }
    }
    
    
    func treeView(_ treeView: RATreeView, commit editingStyle: UITableViewCellEditingStyle, forRowForItem item: Any) {
        guard editingStyle == .delete else { return; }

        
    }
    
    func treeView(_ treeView: RATreeView, editActionsForItem item: Any) -> [Any] {
        let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Editar", handler:{action, indexpath in
            if let goal = item as? Goal{
                let popUpVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "newGoalPopUp") as! NewGoalVC
                popUpVC.editGoal = goal
                self.addChildViewController(popUpVC)
                popUpVC.view.frame = self.view.frame
                self.view.addSubview(popUpVC.view)
                popUpVC.didMove(toParentViewController: self)
            }else if let task = item as? Task{
                let popUpVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "newTaskPopUp") as! NewTaskVC
                popUpVC.editTask = task
                self.addChildViewController(popUpVC)
                popUpVC.view.frame = self.view.frame
                self.view.addSubview(popUpVC.view)
                popUpVC.didMove(toParentViewController: self)
            }
            self.goals.reloadRows()
        });
        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            var index: Int = 0
            if let goal = item as? Goal{
                let alert = UIAlertController(title: "¿Borrar meta?", message: "Si se borra la meta se borrán también las tareas que pertenecen a la meta", preferredStyle: .alert)
                let actioncontinue = UIAlertAction(title: "Eliminar", style: .cancel, handler: {
                    actioncontinue in
                    index = self.goalLst.index(where: { Goal in
                        return Goal === goal;
                    })!
                    Store.deleteGoal(goal)
                    self.goalLst.remove(at: index)
                    self.goals.deleteItems(at: IndexSet(integer: index), inParent: nil, with: RATreeViewRowAnimation.init(1))
                })
                let actiondenny = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
                alert.addAction(actiondenny)
                alert.addAction(actioncontinue)
                self.present(alert, animated: true, completion: nil)
            }else if let task = item as? Task{
                let parent = self.goals.parent(forItem: task) as? Goal
                index = (parent?.tasks.index(where: { Task in
                    return Task === task
                })!)!
                parent?.removeTask(task)
                Store.deleteTask(task)
                self.goals.deleteItems(at: IndexSet(integer: index), inParent: parent, with: RATreeViewRowAnimation.init(1))
            }
            self.goals.reloadRows()
        });
        let doneRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Hecho", handler:{action, indexpath in
            let item = item as! Task
            let cell = treeView.cell(forItem: item) as! TreeTableViewCell
            cell.done()
            item.finished = true
            Store.saveTask(item, Goal())
            self.goals.reloadData()
        });
        doneRowAction.backgroundColor = UIColor.lightGray
        if item is Task{
            return [deleteRowAction, moreRowAction, doneRowAction];
        }
        return[deleteRowAction, moreRowAction]
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
