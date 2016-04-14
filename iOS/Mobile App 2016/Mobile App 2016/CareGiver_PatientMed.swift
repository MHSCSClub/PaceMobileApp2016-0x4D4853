//
//  Caregiver_PatientOverview.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 3/17/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class CareGiver_PatientMed: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    
   
    
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var addButton: UIBarButtonItem!
    var counter = 0
    var indexPath:NSIndexPath!
    
    let textCellIdentifier = "TextCell"
    let dateFormatter = NSDateFormatter()
    
    @IBOutlet var labelForPresent: UILabel!
    var patient:Patient!
    
    var medicationnot = [Medication]()
    
    
    var medicationManager = MedicationManager()
    var scheduleManager = ScheduleManager()
    
    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()
    
    var components:NSDateComponents!
    
    var refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        refreshController.addTarget(self, action: #selector(self.update), forControlEvents: UIControlEvents.ValueChanged)
        //table view
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 70;
        // Do any additional setup after loading the view.
        tableView.addSubview(refreshController)
        
        /*
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 5)
        notification.alertBody = "Take Lipitor 3 Pills"
        notification.alertAction = "Take Lipitor"
        notification.soundName = "takemed.m4a"
        notification.category = "INVITE_CATEGORY";
        notification.userInfo = ["Medication": "Lipitor"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        */
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        components = calendar.components([.Month, .Year, .Day],fromDate: date);
        
        
        if(patient != nil){
            navBar.title = patient.name
            medicationManager.getMeds(Constants.getAuthCode(), pid: "\(patient.pid)", completion: getschedule)
            tabBarController?.navigationItem.title = patient.name
            
            tabBarController?.navigationItem.rightBarButtonItem = addButton
            //NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        }
        
    }
    func update() {
        counter = 0;
        medicationnot = []
        //self.refreshController.beginRefreshing()
        medicationManager.getMeds(Constants.getAuthCode(), pid: "\(patient.pid)", completion: getschedule)
        
    }
    
    func updateView() {
        counter += 1;
        
        if(counter == scheduleManager.schedules.count){
            var medsused = Set<Int>()
            
            scheduleManager.sort()
            for schedule in scheduleManager.schedules {
                for meds in schedule.medications {
                    medsused.insert(meds.medid)
                }
            }
            for meds in medicationManager.medications {
                if(!medsused.contains(meds.medid)){
                    medicationnot.append(meds)
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                //self.medication = self.medicationManager.medications
                self.tableView.reloadData()
                self.refreshController.endRefreshing()
            }
        }
    }
    func getschedule() {
        scheduleManager.getMedsPatient(Constants.getAuthCode(), pid: "\(patient.pid)", completion: connectMeds)
    }
    func connectMeds() {
        scheduleManager.getSceduleDate(Constants.getAuthCode(), pid: "\(patient.pid)", medManager: medicationManager, completion: updateView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(medicationnot.count > 0){
            return scheduleManager.schedules.count + 1
        }
        return scheduleManager.schedules.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexPath = indexPath
        
        self.performSegueWithIdentifier("ShowMedDetail", sender: self)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == scheduleManager.schedules.count){
            return "Unscheduled"
        }
        let ampm = (scheduleManager.schedules[section].hours >= 12 ? " PM" : " AM")
        let min = scheduleManager.schedules[section].minutes < 10 ? "0\(scheduleManager.schedules[section].minutes)" : "\(scheduleManager.schedules[section].minutes)"
        let hour = scheduleManager.schedules[section].hours % 12 == 0 ? "12" : "\(scheduleManager.schedules[section].hours % 12)"
        
        
        return "\(hour):\(min)\(ampm)"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == scheduleManager.schedules.count){
            return medicationnot.count
        }
        return scheduleManager.schedules[section].medications.count
        
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == scheduleManager.schedules.count){
            let row = indexPath.row
            let cell = tableView.dequeueReusableCellWithIdentifier("Meds") as! MedCell
            cell.title.text = "\(medicationnot[row].name)"
            cell.subtitle.textColor = UIColor.blackColor()
            cell.subtitle.text = "\(medicationnot[row].remain) pills left"
            cell.remaining.hidden = true
            if(medicationnot[row].remain < medicationnot[row].dosage){
                cell.subtitle.textColor = UIColor(red: 0.96, green: 0.26 , blue: 0.21, alpha: 0.90)
                
            }
            return cell;
            
        }
       let cell = tableView.dequeueReusableCellWithIdentifier("Meds") as! MedCell
        
        
        let section = indexPath.section
        let row = indexPath.row
        cell.title.text = "\(scheduleManager.schedules[section].medications[row].name)"
        cell.subtitle.textColor = UIColor.blackColor()
        cell.subtitle.text = "\(scheduleManager.schedules[section].medications[row].remain) pills left"
        cell.remaining.hidden = false
        
        
        let takeDate = dateFormatter.dateFromString("\(components.year)-\(components.month)-\(components.day) \(scheduleManager.schedules[section].hours):\(scheduleManager.schedules[section].minutes)")
        
        
        
        let calendar = NSCalendar.currentCalendar()
        let components2 = calendar.components([.Day], fromDate: scheduleManager.schedules[section].taken[row])
        let day = components2.day
        
        
        if(takeDate?.compare(NSDate()) == NSComparisonResult.OrderedDescending){
            cell.remaining.layer.cornerRadius = 8
            cell.remaining.layer.borderWidth =  1
            cell.remaining.backgroundColor = UIColor.whiteColor()
            cell.remaining.layer.borderColor = UIColor(red: 0.96, green: 0.26 , blue: 0.21, alpha: 0.90).CGColor
            cell.remaining.textColor = UIColor(red: 0.96, green: 0.26 , blue: 0.21, alpha: 0.90)
            cell.remaining.text = "Pending"
        }else if(components.day != day){
            cell.remaining.backgroundColor = UIColor(red: 0.96, green: 0.26 , blue: 0.21, alpha: 0.80)
            cell.remaining.layer.cornerRadius = 8
            cell.remaining.layer.masksToBounds = true
            cell.remaining.textColor = UIColor.whiteColor()
            cell.remaining.layer.borderColor = UIColor.clearColor().CGColor
            cell.remaining.text = "Missed"
        }else{
            cell.remaining.backgroundColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80)
            cell.remaining.layer.cornerRadius = 8
            cell.remaining.layer.masksToBounds = true
            cell.remaining.textColor = UIColor.whiteColor()
            cell.remaining.layer.borderColor = UIColor.clearColor().CGColor
            cell.remaining.text = "Taken"
        }
       
        if(scheduleManager.schedules[section].medications[row].remain < scheduleManager.schedules[section].medications[row].dosage){
            cell.subtitle.textColor = UIColor(red: 0.96, green: 0.26 , blue: 0.21, alpha: 0.90)
            
        }
        
        return cell
    }
    
    @IBAction func addMed(sender: AnyObject) {
        let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("Menu")
        let nav = UINavigationController(rootViewController: popoverContent!)
        nav.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = nav.popoverPresentationController
        popoverContent!.preferredContentSize = CGSizeMake(500,600)
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = CGRectMake(100,100,0,0)
        
        self.presentViewController(nav, animated: true, completion: nil)
        
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:CreateMedViewController = (storyboard.instantiateViewControllerWithIdentifier("CreateMedViewController") as? CreateMedViewController)!
        vc.patient = patient
        self.presentViewController(vc, animated: false, completion: nil)*/
    }
    @IBAction func addTime(sender: AnyObject) {
        
        
        /*self.presentViewController(nav, animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:AddScheduleViewController = (storyboard.instantiateViewControllerWithIdentifier("AddScheduleViewController") as? AddScheduleViewController)!
        vc.patient = patient
        vc.medicationList = medicationManager
        self.presentViewController(vc, animated: false, completion: nil)*/
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "popoverSegue"){
            let popoverViewController = segue.destinationViewController as? Popup
            popoverViewController!.modalPresentationStyle = UIModalPresentationStyle.Popover
            //popoverViewController.popoverPresentationController?.sourceView = labelForPresent as UIView
            popoverViewController!.popoverPresentationController!.delegate = self
            popoverViewController?.addMedCall = addMedication
            popoverViewController?.addScheduleCall = addSchedule
            
        }
        else if(segue.identifier == "addMedication"){
            let controller = segue.destinationViewController as? CreateMedViewController
            controller?.patient = patient
            controller?.callback = update
        }
        else if (segue.identifier == "addSchedule"){
            let controller = segue.destinationViewController as? AddScheduleViewController
            controller?.patient = patient
            controller?.callback = update
            controller?.medicationList = medicationManager
        }
        else if(segue.identifier == "ShowMedDetail"){
            let controller = segue.destinationViewController as? MedInfoViewController
            controller?.patient = patient
            if(indexPath.section == scheduleManager.schedules.count){
                controller?.medication = medicationnot[indexPath.row]
            }else{
                controller?.medication = scheduleManager.schedules[indexPath.section].medications[indexPath.row]
            }
            
            
        }
    }
    func addMedication(){
        self.performSegueWithIdentifier("addMedication", sender: self)
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    func addSchedule(){
        self.performSegueWithIdentifier("addSchedule", sender: self)
    }
    
    /*
    // MARK: - Navigation addSchedule
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
