//
//  Caregiver_PatientOverview.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 3/17/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class CareGiver_PatientMed: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
   
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var patientName: UILabel!
    @IBOutlet var med_invitory: UILabel!
    @IBOutlet var tableView: UITableView!
    

    
    let textCellIdentifier = "TextCell"
    
    var patient:Patient!
    
    var medication = [Medication]()
    var medicationManager = MedicationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add line seperaters
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGrayColor().CGColor
        border.frame = CGRect(x: 0, y: med_invitory.frame.size.height - width, width:  med_invitory.frame.size.width, height: med_invitory.frame.size.height)
        border.borderWidth = width
        
        let topBorder = CALayer()
        topBorder.frame = CGRectMake(0, 0, med_invitory.frame.size.width, width)
        topBorder.backgroundColor = UIColor.grayColor().CGColor
        
        //med_invitory.layer.addSublayer(border)
        med_invitory.layer.addSublayer(topBorder)
        med_invitory.layer.masksToBounds = true;
        
        //table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 70;
        // Do any additional setup after loading the view.
        
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
        
        if(patient != nil){
            patientName.text = patient.name
            medicationManager.getMeds(Constants.getAuthCode(), pid: "\(patient.pid)", completion: updateView)
        }
    }
    
    func updateView() {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.medication = self.medicationManager.medications
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medication.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
            reuseIdentifier: "cell")
        
        let row = indexPath.row
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 25)
        cell.textLabel?.text = "\(medication[row].remain) \(medication[row].name) Left"
        
        cell.detailTextLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        cell.detailTextLabel?.text = "Dose: \(medication[row].dosage)"
        
        cell.detailTextLabel?.textColor = UIColor.blueColor()
        cell.textLabel?.textColor = UIColor.blueColor()
        
        if(medication[row].dosage >= medication[row].remain){
            cell.detailTextLabel?.textColor = UIColor.redColor()
            cell.textLabel?.textColor = UIColor.redColor()
        }
        
        return cell
    }
    
    @IBAction func addMed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:CreateMedViewController = (storyboard.instantiateViewControllerWithIdentifier("CreateMedViewController") as? CreateMedViewController)!
        vc.patient = patient
        self.presentViewController(vc, animated: false, completion: nil)
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
