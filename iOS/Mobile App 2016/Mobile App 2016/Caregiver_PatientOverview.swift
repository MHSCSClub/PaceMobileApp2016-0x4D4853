//
//  Caregiver_PatientOverview.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 3/17/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class Caregiver_PatientOverview: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var patientName: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var latestMedication: UILabel!
    @IBOutlet var status_static: UILabel!
    @IBOutlet var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"
    
    var history = [MedHistory(date: "3/17/16 10 AM", med: "Lipitor"), MedHistory(date: "3/16/16 10 AM", med: "Lipitor")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add line seperaters
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGrayColor().CGColor
        border.frame = CGRect(x: 0, y: status_static.frame.size.height - width, width:  status_static.frame.size.width, height: status_static.frame.size.height)
        border.borderWidth = width
        
        let topBorder = CALayer()
        topBorder.frame = CGRectMake(0, 0, status_static.frame.size.width, width)
        topBorder.backgroundColor = UIColor.grayColor().CGColor
        
        status_static.layer.addSublayer(border)
        status_static.layer.addSublayer(topBorder)
        status_static.layer.masksToBounds = true;
        
        //table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 70;

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                reuseIdentifier: "cell")
        
        let row = indexPath.row
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 25)
        cell.textLabel?.text = history[row].med
        cell.detailTextLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        cell.detailTextLabel?.text = history[row].date
        
        return cell
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
