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
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patientList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:UITabBarController = (storyboard.instantiateViewControllerWithIdentifier("PatientView") as? UITabBarController)!
        let viewcontroller1 = vc.viewControllers![0] as? Caregiver_PatientOverview;
        viewcontroller1?.patient = patientList[indexPath.row]
        let viewcontroller2 = vc.viewControllers![1] as? CareGiver_PatientMed;
        viewcontroller2?.patient = patientList[indexPath.row]
        
        self.presentViewController(vc, animated: false, completion: nil)

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
    
    
    
}

