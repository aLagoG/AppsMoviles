//
//  ViewController.swift
//  calendarView
//
//  Created by Héctor Iván Aguirre Arteaga on 19/10/17.
//  Copyright © 2017 Héctor Iván Aguirre Arteaga. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController{
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var myDayTableView: UITableView!
    
    let tasks = Store.getTasks()
    var tasksNames:[String] = []

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
        
        if (!tasks.isEmpty){
            for item in tasks {
                tasksNames.append(item.name)
            }
        }
    
        
    }
    
    func didDoubleTapCollectionView(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: gesture.view!)
        let cellState = calendarView.cellStatus(at: point)
        print(cellState!.date)
        self.formatter.dateFormat = "MMMM dd"
        day.text = self.formatter.string(from: cellState!.date)
        
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
            validCell.dateLabel.textColor = UIColor.white
        } else {
            if cellstate.dateBelongsTo == .thisMonth{
                validCell.dateLabel.textColor = UIColor.black
            } else {
                validCell.dateLabel.textColor = UIColor.gray
            }
            
        }
        
    }
    
    func handleCellSelected(view: JTAppleCell?, cellstate: CellState){
        guard let validCell = view as? CellController else {return}
        if validCell.isSelected{
            validCell.selectedView.isHidden = false
        }else{
            validCell.selectedView.isHidden = true
        }
    }


}

extension ViewController: JTAppleCalendarViewDataSource{
    
    
    
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

extension ViewController: JTAppleCalendarViewDelegate{
    
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CellController", for: indexPath) as! CellController
        cell.dateLabel.text = cellState.text
        handleCellSelected(view: cell, cellstate: cellState)
        handleCellColor(view: cell, cellstate: cellState)
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CellController", for: indexPath) as! CellController
        cell.dateLabel.text = cellState.text
        handleCellSelected(view: cell, cellstate: cellState)
        handleCellColor(view: cell, cellstate: cellState)
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

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        return cell
    }
    
    
}

