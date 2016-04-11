//
//  AddScheduleViewController.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 4/2/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class AddScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var patient: Patient!
    var medicationList: MedicationManager!
    
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet var time: UIDatePicker!
    var tableView = UITableView()
    
    var selected = [Bool]()
    
    var callback: (() -> Void)!
    
    @IBOutlet var doneMedication: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var frame: CGRect = self.view.frame
        print(navigationController?.navigationBar.frame.size.height)
        frame.origin.y += (navigationController?.navigationBar.frame.size.height)!
        frame.origin.y += 35
        frame.size.height = frame.size.height - 150
        
        tableView.frame = frame
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70;
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        tableView.hidden = true;
        doneMedication.hidden = true;
        
        
        
    }
    @IBAction func addMedication(sender: AnyObject) {
        tableView.hidden = false;
        doneMedication.hidden = false;
        navBar.title = "Pick Medications:"
        
        
    }
    @IBAction func doneMedication(sender: AnyObject) {
        tableView.hidden = true;
        doneMedication.hidden = true;
        navBar.title = "Add Schedule"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicationList.medications.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(!selected[indexPath.row]){
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
            selected[indexPath.row] = true
        }else{
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
            selected[indexPath.row] = false
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                                                   reuseIdentifier: "cell")
        selected.append(false)
        //let row = indexPath.row
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 25)
        cell.textLabel?.text = "\(medicationList.medications[indexPath.row].name)"
        return cell;
    }
    
    @IBAction func done(sender: AnyObject) {
        var meds = ""
        if(selected.count > 0){
            for i in 0 ... selected.count-1 {
                if(selected[i]){
                    meds += "\(medicationList.medications[i].medid),"
                }
            }
            meds.removeAtIndex(meds.endIndex.predecessor())
        }
        
        let components = time.calendar.components([.Hour, .Minute],fromDate: time.date);
        let params = ["hours": "\(components.hour)", "minutes": "\(components.minute)", "medication": meds]
        ServerConnection.postRequest(params, url: "\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(patient.pid)/schedules?authcode=\(Constants.getAuthCode())", completion: complete)
        
    }
    
    func complete(data: NSData) {
        print(NSString(data: data, encoding: NSUTF8StringEncoding));
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let status = json["status"] as? String {
                if (status == "success"){
                    print("success")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.backToScreen()
                    }
                }
            }
        }
        catch {
            print("error serializing JSON: \(error)")
        }
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        backToScreen()
    }
    func backToScreen () {
       navigationController?.popViewControllerAnimated(true)
        if(callback != nil){
            callback()
        }
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
