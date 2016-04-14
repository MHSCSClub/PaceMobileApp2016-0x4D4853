//
//  PatientSettingsViewController.swift
//  Med Together
//
//  Created by Jack Phillips on 4/13/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class PatientSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var share: UIButton!
    @IBOutlet var linkLabel: UILabel!
    
    @IBOutlet var settingTable: UITableView!
    var setting = ["Usability", "Medication"]
    var patient:Patient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(patient != nil){
            print(patient.name)
            update()
        }
        let border = CALayer()
        border.borderColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1.0).CGColor
        border.frame = CGRect(x: 0, y: settingTable.frame.size.height - 1, width:  settingTable.frame.size.width, height: settingTable.frame.size.height)
        border.borderWidth = 1
        
        let topBorder = CALayer()
        topBorder.frame = CGRectMake(0, 0, settingTable.frame.size.width, 1)
        topBorder.backgroundColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1.0).CGColor
        
        self.view.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        
        settingTable.delegate = self
        settingTable.dataSource = self
        settingTable.scrollEnabled = false;
        settingTable.layer.addSublayer(border)
        settingTable.layer.addSublayer(topBorder)
        
        share.layer.cornerRadius = 8
        share.layer.masksToBounds = true
        share.backgroundColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80)
        share.layer.borderColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80).CGColor
        
        
        
    }
    @IBAction func share(sender: AnyObject) {
        let alert = UIAlertController(title: "Share User", message: "Username", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Username"
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            print("Bye")
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.shares(textField.text!)
        }))
        
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    func update(){
        ServerConnection.getRequest("\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(patient.pid)/relink?authcode=\(Constants.getAuthCode())", completion: createDone)
    }
    func shares(user: String){
        ServerConnection.postRequest(["username": user], url: "\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(patient.pid)/share?authcode=\(Constants.getAuthCode())", completion: done)
    }
    func done (data: NSData) {
        print(NSString(data: data, encoding: NSUTF8StringEncoding));
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let status = json["status"] as? String {
                if (status == "success"){
                    print("success")
                }
            }
        }
        catch {
            print("error serializing JSON: \(error)")
        }
    }
    
    func createDone (data: NSData) {
        print(NSString(data: data, encoding: NSUTF8StringEncoding));
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let status = json["status"] as? String {
                if (status == "success"){
                    if let data = json["data"] as? [String: AnyObject]{
                        if let lcode = data["lcode"] as? String {
                            print("lcode:\(lcode)")
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                               self.linkLabel.text = "\(lcode)"
                            }
                            
                        }
                    }
                }
            }
        }
        catch {
            print("error serializing JSON: \(error)")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setting.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("rightDetail")
        cell!.textLabel?.text = setting[row]
        cell!.detailTextLabel?.text = "\(patient.usability)"
        //cell?.imageView!.image = UIImage(named: "icon_10.png")
        if(row == 1){
            cell!.detailTextLabel?.text = "\(patient.medstatus == 1 ? "All Taken" : "Missed")"
           // cell?.imageView!.image = UIImage(named: "icon11.png")
        }
        
        return cell!
        
        
        
    }
}
