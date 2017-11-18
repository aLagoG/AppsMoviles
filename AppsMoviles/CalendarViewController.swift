//
//  CalendarViewController.swift
//  calendarView
//
//

import UIKit
import UserNotifications

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, RATreeViewDelegate, RATreeViewDataSource{
    
    @IBOutlet
    weak var calendar: FSCalendar!
    
    @IBOutlet
    weak var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var rootView: UIView!
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    fileprivate let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    var tasks:[Task] = []
    var tasksPerDay:[String:[Task]] = [:]
    var taskTree : RATreeView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem.image = UIImage.fontAwesomeIcon(name: .calendar, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        tabBarItem.selectedImage = tabBarItem.image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadCalendar()
        self.reloadTree()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesUpperCase]
        
        let scopeGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        self.calendar.addGestureRecognizer(scopeGesture)
        
        self.calendar.locale = NSLocale(localeIdentifier: "es_MX") as Locale
        
        self.calendarHeightConstraint.constant = self.view.bounds.height / 2 - 10
        self.view.layoutIfNeeded()
        
        taskTree = RATreeView(frame: CGRect(x: 0, y: self.calendarHeightConstraint.constant + 21, width: self.view.frame.width, height: self.view.frame.height - self.calendarHeightConstraint.constant + 21 - 50))
        taskTree.register(UINib(nibName: String(describing: TreeTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TreeTableViewCell.self))
        taskTree.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        taskTree.dataSource = self
        taskTree.delegate = self
        taskTree.treeFooterView = UIView()
        taskTree.backgroundColor = .clear
        taskTree.allowsSelection = false
        view.addSubview(taskTree)
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
        if let date = self.calendar.selectedDate{
            if gregorian.component(.month, from: date) != gregorian.component(.month, from: calendar.currentPage){
                self.calendar.deselect(date)
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        self.reloadTree()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.reloadTree()
    }
    
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {
        if let selectedDate = self.calendar.selectedDate{
            if let tasksToday = tasksPerDay[formatter.string(from: selectedDate)]{
                return tasksToday.count
            }
        }
        return 0
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        let cell = treeView.dequeueReusableCell(withIdentifier: String(describing: TreeTableViewCell.self)) as! TreeTableViewCell
        let item = item as! Task
        let level = 0
        cell.setup(withTitle: item.name, detailsText: item.description, level: level, additionalButtonHidden: true)
        if (item.finished == true){
            cell.done()
        }
        cell.setColor(item.priority)
        return cell
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {
        return tasksPerDay[formatter.string(from: self.calendar.selectedDate!)]![index]
    }
    
    func reloadTree(){
        taskTree.reloadData()
    }
    
    func reloadCalendar(){
        self.tasks = Store.getTasks()
        tasksPerDay = [:]
        for task in tasks{
            //hanlde when deadline is same date as recurrent
            let ddl = formatter.string(from: task.deadline)
            if task.recurrent{
                for day in task.recurrentDayIndexes(){
                    var ld = task.recurrentStart
                    while true {
                        ld = gregorian.nextDate(after: ld, matching: DateComponents(weekday: day), matchingPolicy: Calendar.MatchingPolicy.nextTime)!
                        if ld > task.recurrentEnd{
                            break
                        }
                        let frm = formatter.string(from: ld)
                        if frm == ddl{
                            continue
                        }
                        if tasksPerDay[frm] != nil{
                            tasksPerDay[frm]?.append(task)
                        }else{
                            tasksPerDay[frm] = [task]
                        }
                    }
                }
            }
            if tasksPerDay[ddl] != nil{
                tasksPerDay[ddl]?.append(task)
            }else{
                tasksPerDay[ddl] = [task]
            }
        }
        self.calendar.reloadData()
    }
    
    func treeView(_ treeView: RATreeView, editActionsForItem item: Any) -> [Any] {
        let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Editar", handler:{action, indexpath in
            let task = item as? Task
            let popUpVC = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "newTaskPopUp") as! NewTaskVC
            popUpVC.editTask = task
            self.addChildViewController(popUpVC)
            popUpVC.view.frame = self.view.frame
            self.view.addSubview(popUpVC.view)
            popUpVC.didMove(toParentViewController: self)
            self.taskTree.reloadRows()
        });
        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            var index: Int = 0
            let task = item as? Task
            index = (self.tasksPerDay[self.formatter.string(from: self.calendar.selectedDate!)]!.index(where: {Task in
                return Task === task
            }))!
            Store.deleteTask(task!)
            self.tasksPerDay[self.formatter.string(from: self.calendar.selectedDate!)]!.remove(at: index)
            self.taskTree.deleteItems(at: IndexSet(integer: index), inParent: nil, with: RATreeViewRowAnimation.init(1))
            self.reloadCalendar()
            self.reloadTree()
        });
        
        let doneRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Hecho", handler:{action, indexpath in
            let item = item as! Task
            let cell = treeView.cell(forItem: item) as! TreeTableViewCell
            cell.done()
            item.finished = true
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["deadline"])
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["end"])
            Store.saveTask(item, Goal())
            self.taskTree.reloadData()
        });
        doneRowAction.backgroundColor = UIColor.lightGray
        
        let task = item as! Task
        if task.recurrent{
            return [deleteRowAction, moreRowAction];
        }
        return [deleteRowAction, moreRowAction, doneRowAction];
    }
    
    
    func treeView(_ treeView: RATreeView, shouldExpandRowForItem item: Any) -> Bool {
        return false
    }
}

