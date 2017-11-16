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
    
    var editGoal:Goal? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewGoalVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        lowPriority.isHighlighted = true
        lowPriority.isSelected = true
        if let goal = editGoal{
            nameTF.text = goal.name
            descTF.text = goal.description
            startDP.date = goal.startDate
            endDP.date = goal.deadline
            setPriority(goal: goal)
        }
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
        
        if (name.isEmpty){
            displayAlertMessage(message: "¡La meta necesita un nombre!")
        }else{
            let goal = Goal(deadline: end, startDate: start, name: name, priority: self.priority, description: desc, color: UIColor.white, tasks: [])
            if let gl = editGoal{
                goal.id = gl.id
            }
            Store.saveGoal(goal)
            (self.parent as! GoalsViewController).reloadTree()
            self.view.removeFromSuperview()
        }
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
                return
            case "2":
                lowPriority.isSelected = false
                lowPriority.isHighlighted = false
                highPriority.isSelected = false
                highPriority.isHighlighted = false
                self.priority = 2
                return
            case "3":
                lowPriority.isSelected = false
                lowPriority.isHighlighted = false
                mediumPriority.isSelected = false
                mediumPriority.isHighlighted = false
                self.priority = 3
                return
            default:
                lowPriority.isSelected = false
                lowPriority.isHighlighted = false
                mediumPriority.isSelected = false
                mediumPriority.isHighlighted = false
                highPriority.isSelected = false
                highPriority.isHighlighted = false
                self.priority = 1
                return
            }
        }
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func displayAlertMessage (message: String){
        let alert = UIAlertController(title: "No se puede crear la meta", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setPriority(goal: Goal){
        switch(goal.priority){
        case 1:
            lowPriority.isHighlighted = true
            lowPriority.isSelected = true
            mediumPriority.isSelected = false
            mediumPriority.isHighlighted = false
            highPriority.isSelected = false
            highPriority.isHighlighted = false
            return
        case 2:
            lowPriority.isHighlighted = false
            lowPriority.isSelected = false
            mediumPriority.isSelected = true
            mediumPriority.isHighlighted = true
            highPriority.isSelected = false
            highPriority.isHighlighted = false
            return
        case 3:
            lowPriority.isHighlighted = false
            lowPriority.isSelected = false
            mediumPriority.isSelected = false
            mediumPriority.isHighlighted = false
            highPriority.isSelected = true
            highPriority.isHighlighted = true
            return
        default:
            return
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
