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
    
    

    @IBOutlet weak var editButton: UIButton!
    
    var goalLst=[Goal]()
    var goals : RATreeView!
    var expansions: [Int64: Bool] = [Int64: Bool]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        goalLst = Store.getGoals()
        // Do any additional setup after loading the view.
        goals = RATreeView(frame: CGRect(x: 0 , y: 80, width: self.view.frame.width, height: self.view.frame.height * 0.7))
        goals.register(UINib(nibName: String(describing: TreeTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TreeTableViewCell.self))
        goals.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        goals.dataSource = self
        goals.delegate = self
        goals.treeFooterView = UIView()
        goals.backgroundColor = .clear
        view.addSubview(goals)
        
        editButton.titleLabel?.text = "Editar"
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
        if item.debugDescription == "Optional(AppsMoviles.Goal)"{
            let item = item as! Goal
            let doneTasks = item.countTasksDone()
            let detailText = "Tareas hechas: \(doneTasks) de \(item.tasks.count)"
            let level = 0
            cell.selectionStyle = .none
            cell.setup(withTitle: item.name, detailsText: detailText, level: level, additionalButtonHidden: false)

        }else if item.debugDescription == "Optional(AppsMoviles.Task)"{
            let item = item as! Task
            let detailText = item.description
            let level = 1
            cell.selectionStyle = .none
            cell.setup(withTitle: item.name, detailsText: detailText, level: level, additionalButtonHidden: true)
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
    
    func updateNavigationBarButtons() -> Void {
        if (goals.isEditing == true){
            editButton.titleLabel?.text = "Listo"
        }else{
            editButton.titleLabel?.text = "Editar"
        }
    }

    @IBAction func startEditing(_ sender: Any) {
        editButton.titleLabel?.text = "Listo"
        goals.setEditing(!goals.isEditing, animated: true)
    }
    
    func treeView(_ treeView: RATreeView, commit editingStyle: UITableViewCellEditingStyle, forRowForItem item: Any?) {
        guard editingStyle == .delete else { return; }
        var index: Int = 0

        if item.debugDescription == "Optional(AppsMoviles.Goal)"{
            let item = item as! Goal
            index = self.goalLst.index(where: { Goal in
                return Goal === item;
            })!
            print(index)
            Store.deleteGoal(item)
            self.goalLst.remove(at: index)
            self.goals.deleteItems(at: IndexSet(integer: index), inParent: nil, with: RATreeViewRowAnimation.init(1))
        }else if item.debugDescription == "Optional(AppsMoviles.Task)"{
            print("Task")
            let item = item as! Task
            let parent = goals.parent(forItem: item) as? Goal

            index = (parent?.tasks.index(where: { Task in
                return Task === item
            })!)!
            parent?.removeTask(item)
            Store.deleteTask(item)
            self.goals.deleteItems(at: IndexSet(integer: index), inParent: parent, with: RATreeViewRowAnimation.init(1))
        }
            self.goals.reloadRows()
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
