//
//  NewTaskVC.swift
//  AppsMoviles
//
//  Created by Leslie Marjorie Gallegos Salazar on 25/10/17.
//

import UIKit
import UserNotifications

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
    
    @IBOutlet weak var lowPriority: UIButton!
    @IBOutlet weak var mediumPriority: UIButton!
    @IBOutlet weak var highPriority: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var dayButtons:[UIButton] = []
    var priorityButtons: [UIButton] = []
    
    var task = Task()
    var name: String = ""
    var priority :Int64 = 1
    var descr: String = ""
    var deadline: Date = Date.init()
    var place : String = ""
    var recurrent: Bool = true
    var recurrentStart: Date = Date.init()
    var recurrentEnd: Date = Date.init()
    var recurrentDays : [String] = []
    var goal : Goal = Goal()
    
    var editTask:Task? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        changeRecurrent()
        dayButtons = [mondayButton, tuesdayButton,wednesdayButton,thursdayButton,fridayButton,saturdayButton,sundayButton]
        priorityButtons = [lowPriority,mediumPriority,highPriority]
        //Para que cuando el usuario haga tap fuera del teclado, desaparezca
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewTaskVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        //La prioridad por defecto
        lowPriority.isHighlighted = true
        lowPriority.isSelected = true
        if let task = editTask{
            nameTF.text = task.name
            descriptionTF.text = task.description
            deadlineDPV.date = task.deadline
            placeTF.text = task.place
            recurrentSw.isOn = task.recurrent
            initDPV.date = task.recurrentStart
            endDPV.date = task.recurrentEnd
            setPriority(task: task)
            setRecurrent(task: task)
            //falta manejar los recurrent days y la prioridad
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func selected(_ sender: Any) {
        if let button = sender as? UIButton{
            if button.isSelected == false{
                button.isSelected = true
                button.isHighlighted = true
            }else{
                button.isSelected = false
                button.isHighlighted = false
            }
        }
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
                case "2":
                    lowPriority.isSelected = false
                    lowPriority.isHighlighted = false
                    highPriority.isSelected = false
                    highPriority.isHighlighted = false
                case "3":
                    lowPriority.isSelected = false
                    lowPriority.isHighlighted = false
                    mediumPriority.isSelected = false
                    mediumPriority.isHighlighted = false
                default:
                    lowPriority.isSelected = false
                    lowPriority.isHighlighted = false
                    mediumPriority.isSelected = false
                    mediumPriority.isHighlighted = false
                    highPriority.isSelected = false
                    highPriority.isHighlighted = false
            }
        }
    }
    
    
    @IBAction func createTask(_ sender: Any){
        name = nameTF.text!
        descr = descriptionTF.text!
        deadline = deadlineDPV.date
        place = placeTF.text!
        recurrent = recurrentSw.isOn
        recurrentStart = initDPV.date
        recurrentEnd = endDPV.date
        priority = getPriority()
        getRecurrentDays()
        
        if (name.isEmpty){
            displayAlertMessage(message: "¡La tarea necesita un nombre!")
        }else if (recurrent == true && recurrentDays.count == 0){
            displayAlertMessage(message: "Por favor selecciona los días en los que se va a repetir tu tarea")
        }else{
            let newItem = Task(deadline: deadline, name: name, priority: priority, description: descr, place: place, recurrent: recurrent, recurrentStart: recurrentStart, recurrentEnd: recurrentEnd, recurrentDays: recurrentDays)
            if let tsk = editTask{
                newItem.id = tsk.id
            }

            Store.saveTask(newItem, goal)
            if let gvc = self.parent as? GoalsViewController{
                gvc.reloadTree()
            }else if let mdc = self.parent as? MyDayViewController{
                mdc.reloadTree()
            }else if let cvc = self.parent as? CalendarViewController{
                cvc.reloadCalendar()
                cvc.reloadTree()
            }
            self.view.removeFromSuperview()
        }
        
        //Crear Tarea
        //NOTIFICACIONES
        let content = UNMutableNotificationContent()
        content.title = "Haz agregado una nueva tarea"
        content.body = "¿Puedes trabajar en ella?"
        content.badge = 1
        
        let content2 = UNMutableNotificationContent()
        content2.title = "El limite para tu tarea \(name) es hoy"
        content2.body = "¿Ya la terminaste?"
        content2.badge = 1
        
        let calendar = Calendar.current
        var date = DateComponents()
        date.day = calendar.component(.day, from: deadline)
        date.hour = 12
        date.minute = 00
    
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "timerDone", content: content , trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        let triHora = UNCalendarNotificationTrigger(dateMatching: date , repeats: false)
        let request2 = UNNotificationRequest(identifier: "deadline", content: content2 , trigger: triHora)
        UNUserNotificationCenter.current().add(request2, withCompletionHandler: nil)
        
        }
    
    
    @IBAction func cancelTask(_ sender: Any) {
        self.view.removeFromSuperview()
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
            mondayButton.isHighlighted = false
            tuesdayButton.isHighlighted = false
            wednesdayButton.isHighlighted = false
            thursdayButton.isHighlighted = false
            fridayButton.isHighlighted = false
            saturdayButton.isHighlighted = false
            sundayButton.isHighlighted = false
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
    
    func getRecurrentDays(){
        for days in dayButtons{
            if days.isSelected == true{
                recurrentDays.append((days.titleLabel?.text!)!.lowercased())
            }
        }
    }
    
    func getPriority()->Int64{
        var priorityButtonSelected : UIButton = priorityButtons[0]
        for pbutton in priorityButtons{
            if pbutton.isSelected == true{
                priorityButtonSelected = pbutton
            }
        }
        return Int64(priorityButtonSelected.restorationIdentifier!)!
    }

    func displayAlertMessage(message: String){
        let alert = UIAlertController(title: "No se puede crear la tarea", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    func dismissKeyboard(){
        view.endEditing(true)
    }

    func setPriority(task: Task){
        switch(task.priority){
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
    
    func setRecurrent(task: Task){
        if (task.recurrent == true){
            recurrentSw.setOn(true, animated: false)
        }else{
            recurrentSw.setOn(false, animated: false)
        }
        changeRecurrent()
        
        for btn in dayButtons{
            if (task.recurrentDays.contains(btn.titleLabel!.text!.lowercased())){
                btn.isHighlighted = true
                btn.isSelected = true
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
