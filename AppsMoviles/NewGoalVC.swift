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
        
        let goal = Goal(deadline: end, startDate: start, name: name, priority: 0, description: desc, color: UIColor.white, tasks: [])
        Store.saveGoal(goal)
        
        self.view.removeFromSuperview()
    }
    
    @IBAction func cancelButtonClick(_ sender: Any) {
        self.view.removeFromSuperview()
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
