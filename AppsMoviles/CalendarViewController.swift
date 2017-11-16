//
//  CalendarViewController.swift
//  calendarView
//
//

import UIKit

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate{
    
    @IBOutlet
    weak var calendar: FSCalendar!
    
    @IBOutlet
    weak var calendarHeightConstraint: NSLayoutConstraint!
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    
    var tasks:[Task] = []
    var tasksPerDay:[String:[Task]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        
        self.calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesUpperCase]
        
        let scopeGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        self.calendar.addGestureRecognizer(scopeGesture)
        
        self.calendar.locale = NSLocale(localeIdentifier: "es_MX") as Locale
        
        self.tasks = Store.getTasks()
        for task in tasks{
            let day = formatter.string(from: task.deadline)
            if tasksPerDay[day] != nil{
                tasksPerDay[day]?.append(task)
            }else{
                tasksPerDay[day] = [task]
            }
        }
    }
    
    // MARK:- FSCalendarDataSource
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let day = formatter.string(from: date)
        if tasksPerDay[day] != nil{
            return tasksPerDay[day]!.count
        }else{
            return 0
        }
    }

    // MARK:- FSCalendarDelegate
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("change page to \(self.formatter.string(from: calendar.currentPage))")
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("calendar did select date \(self.formatter.string(from: date))")
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
}

