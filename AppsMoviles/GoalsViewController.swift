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
    
    convenience init() {
        self.init(nibName : nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        goalLst = GoalsViewController.commonInit()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
        goalLst = GoalsViewController.commonInit()
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
            let popUpVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "newTaskPopUp") as! NewTaskVC
            self.addChildViewController(popUpVC)
            popUpVC.view.frame = self.view.frame
            self.view.addSubview(popUpVC.view)
            popUpVC.didMove(toParentViewController: self)
            
            //let item = treeView.item(for: cell) as! Goal
            /*let newItem = Task(deadline: Date.init(), name: "T1", priority: 1, description: "T1 des", place: "T1 P")
            item.addTask(newItem)
            treeView.insertItems(at: IndexSet(integer: item.tasks.count-1), inParent: item, with: RATreeViewRowAnimation.init(0))
            treeView.reloadRows(forItems: [item], with: RATreeViewRowAnimation.init(0))*/
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
private extension GoalsViewController {
    
    static func commonInit() -> [Goal] {
        
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
        
        return [g1, g2, g3, g4, g5]
    }
    
}
