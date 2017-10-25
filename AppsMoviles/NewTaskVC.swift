//
//  NewTaskVC.swift
//  AppsMoviles
//
//  Created by Leslie Marjorie Gallegos Salazar on 25/10/17.
//

import UIKit

class NewTaskVC: UIViewController {

  
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var placeTF: UITextField!
    @IBOutlet weak var deadlineDPV: UIDatePicker!
    @IBOutlet weak var recurrentSw: UISwitch!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var sundayButton: UIButton!
    @IBOutlet weak var initDPV: UIDatePicker!
    @IBOutlet weak var endDPV: UIDatePicker!
    @IBOutlet weak var initLbl: UILabel!
    @IBOutlet weak var endLbl: UILabel!
    
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var task = Task()
    var name: String = ""
    var descr: String = ""
    var deadline: Date = Date.init()
    var place : String = ""
    var recurrent: Bool = true
    var recurrentStart: Date = Date.init()
    var recurrentEnd: Date = Date.init()
    var recurrentDays : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        doneButton.setImage(UIImage.fontAwesomeIcon(name: .check, textColor: UIColor.black, size: CGSize(width: 40, height:40)), for: .normal)
        cancelButton.setImage(UIImage.fontAwesomeIcon(name: .times, textColor: UIColor.black, size: CGSize(width:40, height:40)), for: .normal)
        changeRecurrent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createTask(_ sender: Any) {
        name = nameTF.text!
        descr = descriptionTF.text!
        deadline = deadlineDPV.date
        place = placeTF.text!
        recurrent = recurrentSw.isOn
        recurrentStart = initDPV.date
        recurrentEnd = endDPV.date
        //recurrentDays = getRecurrentDays()
        
        self.view.removeFromSuperview()
        
        //Crear Tarea
        }
    
    
    @IBAction func recurrentChange(_ sender: Any) {
        changeRecurrent()
    }
    
    
    func changeRecurrent(){
        if recurrentSw.isOn == false {
            mondayButton.isEnabled = false
            tuesdayButton.isEnabled = false
            wednesdayButton.isEnabled = false
            thursdayButton.isEnabled = false
            fridayButton.isEnabled = false
            saturdayButton.isEnabled = false
            sundayButton.isEnabled = false
            initDPV.isEnabled = false
            endDPV.isEnabled = false
            mondayButton.setTitleColor(UIColor.lightGray, for: .normal)
            tuesdayButton.setTitleColor(UIColor.lightGray, for: .normal)
            wednesdayButton.setTitleColor(UIColor.lightGray, for: .normal)
            thursdayButton.setTitleColor(UIColor.lightGray, for: .normal)
            fridayButton.setTitleColor(UIColor.lightGray, for: .normal)
            saturdayButton.setTitleColor(UIColor.lightGray, for: .normal)
            sundayButton.setTitleColor(UIColor.lightGray, for: .normal)
            initLbl.textColor = UIColor.lightGray
            endLbl.textColor = UIColor.lightGray
        }else{
            mondayButton.isEnabled = true
            tuesdayButton.isEnabled = true
            wednesdayButton.isEnabled = true
            thursdayButton.isEnabled = true
            fridayButton.isEnabled = true
            saturdayButton.isEnabled = true
            sundayButton.isEnabled = true
            initDPV.isEnabled = true
            endDPV.isEnabled = true
            mondayButton.setTitleColor(UIColor.blue, for: .normal)
            tuesdayButton.setTitleColor(UIColor.blue, for: .normal)
            wednesdayButton.setTitleColor(UIColor.blue, for: .normal)
            thursdayButton.setTitleColor(UIColor.blue, for: .normal)
            fridayButton.setTitleColor(UIColor.blue, for: .normal)
            saturdayButton.setTitleColor(UIColor.blue, for: .normal)
            sundayButton.setTitleColor(UIColor.blue, for: .normal)
            initLbl.textColor = UIColor.black
            endLbl.textColor = UIColor.black
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
