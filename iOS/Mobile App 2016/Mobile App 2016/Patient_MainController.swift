//
//  Patient_MainController.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 4/1/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit
import AVFoundation

class Patient_MainController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var takeNowLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    //var tableTakeNow = UITableView()
    @IBOutlet var tableTakeNow: UITableView!
    let textCellIdentifier = "TextCell"
    
    var task:NSTimer!
    
    var counter = 0;
    
    
    var medicationManager = MedicationManager()
    var scheduleManager = ScheduleManager()
    var heightofSection:CGFloat = 40
    var fontofSection:CGFloat = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = true
        //add line seperaters
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.blackColor().CGColor
        border.frame = CGRect(x: 0, y: takeNowLabel.frame.size.height - width, width:  takeNowLabel.frame.size.width, height: takeNowLabel.frame.size.height)
        border.borderWidth = width
        
        let topBorder = CALayer()
        topBorder.frame = CGRectMake(0, 0, timeLabel.frame.size.width, width)
        topBorder.backgroundColor = UIColor.blackColor().CGColor
        
        
        //med_invitory.layer.addSublayer(border)
        //takeNowLabel.layer.addSublayer(topBorder)
        //takeNowLabel.layer.addSublayer(border)
        //takeNowLabel.layer.masksToBounds = true;
        
        
        //var frame: CGRect = self.view.frame
        //frame.origin.y += 130
        //frame.size.height = frame.size.height - 130
        
        //tableTakeNow.frame = frame
        tableTakeNow.delegate = self
        tableTakeNow.dataSource = self
        tableTakeNow.rowHeight = 75;
        //tableTakeNow.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.setNeedsStatusBarAppearanceUpdate()
        
        
        //timeLabel.backgroundColor = UIColor.clearColor()
        //imageView.image = UIImage(named: "Night2.png")
        
        
        
        
        
        updateTime()
        update()
        self.view.bringSubviewToFront(timeLabel)
        task = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(Patient_MainController.updateTime), userInfo: nil, repeats: true)
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()){
            [unowned self] notification in
            self.update()
            self.counter = 0
        }
        
        
        //self.view.addSubview(tableTakeNow)
        
    }
   
    func update(not:NSNotificationCenter) -> Void{
        medicationManager.getMedsPatient(Constants.getAuthCode(), completion: getschedule)
    }
    func update() -> Void{
        medicationManager.getMedsPatient(Constants.getAuthCode(), completion: getschedule)
    }
    
    func updateView() {
        print(scheduleManager.schedules.count)
        counter += 1;
        
        if(counter == scheduleManager.schedules.count){
            print("Here")
            let late = scheduleManager.getLateMeds()
            if(late.count != 0){
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc:MedReminder = storyboard.instantiateViewControllerWithIdentifier("MedReminder") as! MedReminder
                    vc.meds = late
                    self.presentViewController(vc, animated: true, completion: nil)
                    self.task.invalidate()
                    
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                //self.medication = self.medicationManager.medications
                self.tableTakeNow.reloadData()
            }

        }
    }
    func getschedule() {
        scheduleManager.getSchedulePatient(Constants.getAuthCode(), completion: connectMeds)
    }
    func connectMeds() {
        scheduleManager.getSceduleDate(Constants.getAuthCode(), medManager: medicationManager, completion: updateView)
    }
    
    func updateTime(){
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute],fromDate: date);
        
        let hour = components.hour % 12 == 0 ? "12" : "\(components.hour % 12)"
        let minute = components.minute < 10 ? "0\(components.minute)" : "\(components.minute)"
        timeLabel.text = "\(hour):\(minute)"
        print("\(hour):\(minute)")
        if(components.hour < 6){
            imageView.image = UIImage(named: "Night2.png")
        }
        else if(components.hour < 9){
            imageView.image = UIImage(named: "Dawn2.png")
        }
        else if(components.hour < 13){
            imageView.image = UIImage(named: "day2.png")
        }else if(components.hour < 18){
            imageView.image = UIImage(named: "Dusk.png")
        }else{
            imageView.image = UIImage(named: "Night2.png")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return scheduleManager.schedules.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let ampm = (scheduleManager.schedules[section].hours >= 12 ? " PM" : " AM")
        let min = scheduleManager.schedules[section].minutes < 10 ? "0\(scheduleManager.schedules[section].minutes)" : "\(scheduleManager.schedules[section].minutes)"
        let hour = scheduleManager.schedules[section].hours % 12 == 0 ? "12" : "\(scheduleManager.schedules[section].hours % 12)"
        
        
        return "\(hour):\(min)\(ampm)"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleManager.schedules[section].medications.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, heightofSection)) //set these values as necessary
        returnedView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        
        let label = UILabel(frame: CGRectMake(15, 0, self.view.frame.width - 20, heightofSection))
        
        label.font = UIFont.boldSystemFontOfSize(fontofSection)
        let ampm = (scheduleManager.schedules[section].hours >= 12 ? " PM" : " AM")
        let min = scheduleManager.schedules[section].minutes < 10 ? "0\(scheduleManager.schedules[section].minutes)" : "\(scheduleManager.schedules[section].minutes)"
        let hour = scheduleManager.schedules[section].hours % 12 == 0 ? "12" : "\(scheduleManager.schedules[section].hours % 12)"
        
        label.text = "\(hour):\(min)\(ampm)"
        label.textColor = UIColor(red: 58/255, green: 58/255, blue: 60/255, alpha: 0.80)
        returnedView.addSubview(label)
        
        return returnedView
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightofSection
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("PatientCell") as! PatientCell
        cell.amount.backgroundColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80)
        cell.amount.layer.cornerRadius = 8
        cell.amount.layer.masksToBounds = true
        cell.amount.textColor = UIColor.whiteColor()
        cell.amount.layer.borderColor = UIColor.clearColor().CGColor
        cell.amount.text = "Take \(scheduleManager.schedules[section].medications[row].dosage)"
        /*
        cell.amount.layer.cornerRadius = 8
        cell.amount.layer.borderWidth =  1
        cell.amount.backgroundColor = UIColor.whiteColor()
        cell.amount.layer.borderColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80).CGColor
        cell.amount.textColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80)
        cell.amount.text = "Take \(scheduleManager.schedules[section].medications[row].dosage)"*/
        
        
        cell.medName.text = "\(scheduleManager.schedules[section].medications[row].name)"
        return cell;
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
        
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}