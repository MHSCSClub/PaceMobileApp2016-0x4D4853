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
    
    var refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70;
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        refreshController.addTarget(self, action: #selector(PatientListViewController.update), forControlEvents: UIControlEvents.ValueChanged)
        //self.refreshControl = refreshController
        
        navigationController!.navigationBar.barTintColor = UIColor.init(red: 0.13, green: 0.59 , blue: 0.95, alpha: 1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.tintColor = UIColor.whiteColor();
        tableView.addSubview(refreshController)
        setNeedsStatusBarAppearanceUpdate()
        
        //nava
        
        patientmanager.getpatients(Constants.getAuthCode(), completion: updateView)
        
        
    }
    func update() {
        patientmanager.patients = []
        patientmanager.getpatients(Constants.getAuthCode(), completion: updateView)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func updateView() {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.patientList = self.patientmanager.patients
            self.tableView.reloadData()
            self.refreshController.endRefreshing()
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
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if (segue.identifier == "PatientMeds") {
            let tabviewController = segue.destinationViewController as? UITabBarController
            let viewController = tabviewController?.childViewControllers[0] as? CareGiver_PatientMed
            viewController?.patient = patientList[selected]
            
        }
        else if(segue.identifier == "AddPatient"){
            let viewController = segue.destinationViewController as? AddPatinetCaregiver
            viewController?.callback = update
        }
        
        
        
        
    }
    
    
}

