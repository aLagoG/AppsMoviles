//
//  CalendarViewController.swift
//  calendarView
//
//  Created by Héctor Iván Aguirre Arteaga on 19/10/17.
//  Copyright © 2017 Héctor Iván Aguirre Arteaga. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController{
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var myDayTableView: UITableView!
    

    
    
    var tasks: [Task] = []
    var tasksNames:[String] = []
    var tasksDesc:[String] = []
    
    let formatter = DateFormatter()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem.image = UIImage.fontAwesomeIcon(name: .calendar, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        tabBarItem.selectedImage = tabBarItem.image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCalendarView()
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.selectDates([Date()])
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapCollectionView(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2  // add double tap
        calendarView.addGestureRecognizer(doubleTapGesture)
        self.myDayTableView.separatorColor = UIColor(hue: 0.2333, saturation: 1, brightness: 0.56, alpha: 1.0)
        self.myDayTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLineEtched
        tasks = Store.getTasks()
        
    }
    
    func didDoubleTapCollectionView(gesture: UITapGestureRecognizer) {
    }
    
    
    
    
    func setupCalendarView(){
        //Setup calendar spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        //Setup calendar labels
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        
        
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        self.formatter.dateFormat = "yyyy"
        self.year.text = self.formatter.string(from: date)
        
        self.formatter.dateFormat = "MMMM"
        self.month.text = self.formatter.string(from: date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleCellColor(view: JTAppleCell?, cellstate: CellState){
        guard let validCell = view as? CellController else { return }
        if cellstate.isSelected {
            validCell.dateL.textColor = UIColor.white
        } else {
            if cellstate.dateBelongsTo == .thisMonth{
                validCell.dateL.textColor = UIColor.black
            } else {
                validCell.dateL.textColor = UIColor.gray
            }
            
        }
        
    }
    
    
    
    
    func handleCellSelected(view: JTAppleCell?, cellstate: CellState){
        guard let validCell = view as? CellController else {return}
        if validCell.isSelected{
            tasksNames.removeAll()
            tasksDesc.removeAll()
            validCell.selectedV.isHidden = false
            self.formatter.dateFormat = "MMMM dd"
            day.text = self.formatter.string(from: cellstate.date)
            tasks = Store.getTasks()
            print(tasks)
            self.formatter.dateFormat = "yyyy MM dd"
            if (!tasks.isEmpty){
                for item in tasks {
                    if(self.formatter.string(from: cellstate.date)==self.formatter.string(from: item.deadline)){
                        tasksNames.append(item.name)
                        tasksDesc.append(item.description)
                    }
                }
            }else {
                tasksNames.append("Sin eventos")
            }
            myDayTableView.reloadData()
            
        }else{
            validCell.selectedV.isHidden = true
        }
    }
    
    
}

extension CalendarViewController: JTAppleCalendarViewDataSource{
    
    
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale  = Calendar.current.locale
        
        let startDate = formatter.date(from: "1996 01 01")!
        let endDate = formatter.date(from: "2025 01 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
    
    
}

extension CalendarViewController: JTAppleCalendarViewDelegate{
    
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CellController", for: indexPath) as! CellController
        cell.dateL.text = cellState.text
        
        
        
        
        handleCellSelected(view: cell, cellstate: cellState)
        handleCellColor(view: cell, cellstate: cellState)
        
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CellController", for: indexPath) as! CellController
        cell.dateL.text = cellState.text
        
        
        handleCellSelected(view: cell, cellstate: cellState)
        handleCellColor(view: cell, cellstate: cellState)
        self.formatter.dateFormat = "yyyy MM dd"
        if (!tasks.isEmpty){
            for item in tasks {
                if(self.formatter.string(from: cellState.date)==self.formatter.string(from: item.deadline)){
                    switch item.priority {
                    case 1 : cell.pri1.isHidden = false
                    case 2 : cell.pri2.isHidden = false
                    case 3 : cell.pri3.isHidden = false
                        
                    default:
                        break
                        
                    }
                }else {
                    cell.pri1.isHidden = true
                    cell.pri2.isHidden = true
                    cell.pri3.isHidden = true
                }
            }
        }
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellstate: cellState)
        handleCellColor(view: cell, cellstate: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellstate: cellState)
        handleCellColor(view: cell, cellstate: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        if(!tasksNames.isEmpty){
            cell.textLabel?.text = tasksNames[indexPath.row]
            cell.detailTextLabel?.text = tasksDesc[indexPath.row]
            
        }
        return cell
    }
    
    
}

