//
//  PatientSettingsViewController.swift
//  Med Together
//
//  Created by Jack Phillips on 4/13/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class PatientSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var linkLabel: UILabel!
    @IBOutlet var usernameShare: UITextField!
    @IBOutlet var settingTable: UITableView!
    var setting = ["Usability"]
    var patient:Patient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(patient != nil){
            print(patient.name)
            update()
        }
        settingTable.delegate = self
        settingTable.dataSource = self
        settingTable.scrollEnabled = false;
        
        
        
    }
    @IBAction func share(sender: AnyObject) {
        shares()
    }
    func update(){
        ServerConnection.getRequest("\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(patient.pid)/relink?authcode=\(Constants.getAuthCode())", completion: createDone)
    }
    func shares(){
        ServerConnection.postRequest(["username": usernameShare.text!], url: "\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(patient.pid)/share?authcode=\(Constants.getAuthCode())", completion: done)
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
                               self.linkLabel.text = "Link Code: \(lcode)"
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
        return cell!
          
        
        
        
    }
}
