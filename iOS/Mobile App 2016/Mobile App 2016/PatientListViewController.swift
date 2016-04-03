//
//  ViewController.swift
//  API
//
//  Created by Jack Phillips on 3/4/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class PatientListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"
    
    var patientmanager = PatientManager()
    
    var patientList: [Patient] = []
    var selected = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70;
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        patientmanager.getpatients(Constants.getAuthCode(), completion: updateView)
        
        
    }
    
    func updateView() {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.patientList = self.patientmanager.patients
            self.patientList.append(Patient(pid: "7", name: "jack", active: "1"))
            self.patientList.append(Patient(pid: "7", name: "jack", active: "1"))
            self.patientList.append(Patient(pid: "7", name: "jack", active: "1"))
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patientList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected = indexPath.row
        
        self.performSegueWithIdentifier("PatientMeds", sender: self)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
            reuseIdentifier: "cell")
        
        let row = indexPath.row
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 25)
        cell.textLabel?.text = "\(patientList[row].name)"
        
        if(patientList[row].active == 1){
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if (segue.identifier == "PatientMeds") {

            let viewController = segue.destinationViewController as? CareGiver_PatientMed
            viewController?.patient = patientList[selected]
        }
        
        
        
    }
    
    
}

