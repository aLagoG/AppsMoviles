//
//  NewGoalVC.swift
//  AppsMoviles
//
//  Created by Andrés De Lago Gómez on 01/11/17.
//

import UIKit

class NewGoalVC: UIViewController {

    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descTF: UITextField!
    @IBOutlet weak var startDP: UIDatePicker!
    @IBOutlet weak var endDP: UIDatePicker!
    
    @IBOutlet weak var lowPriority: UIButton!
    @IBOutlet weak var mediumPriority: UIButton!
    @IBOutlet weak var highPriority: UIButton!
    
    var priority: Int64 = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        let name = nameTF.text!
        let desc = descTF.text!
        let start = startDP.date
        let end = endDP.date
        
        let goal = Goal(deadline: end, startDate: start, name: name, priority: self.priority, description: desc, color: UIColor.white, tasks: [])
        Store.saveGoal(goal)
        
        (self.parent as! GoalsViewController).reloadTree()
        self.view.removeFromSuperview()
    }
    
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    @IBAction func clickPriority(_ sender: Any) {
        if let button = sender as? UIButton{
            button.isSelected = true
            button.isHighlighted = true
            switch button.restorationIdentifier!{
            case "1":
                mediumPriority.isSelected = false
                mediumPriority.isHighlighted = false
                highPriority.isSelected = false
                highPriority.isHighlighted = false
                self.priority = 1
            case "2":
                lowPriority.isSelected = false
                lowPriority.isHighlighted = false
                highPriority.isSelected = false
                highPriority.isHighlighted = false
                self.priority = 2
            case "3":
                lowPriority.isSelected = false
                lowPriority.isHighlighted = false
                mediumPriority.isSelected = false
                mediumPriority.isHighlighted = false
                self.priority = 3
            default:
                lowPriority.isSelected = false
                lowPriority.isHighlighted = false
                mediumPriority.isSelected = false
                mediumPriority.isHighlighted = false
                highPriority.isSelected = false
                highPriority.isHighlighted = false
                self.priority = 1
            }
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
