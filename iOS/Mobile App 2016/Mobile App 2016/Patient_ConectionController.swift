//
//  Patient_ConectionController.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 3/31/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class Patient_ConectionController: UIViewController {
    @IBOutlet var conectionCode: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func register(sender: AnyObject) {
        ServerConnection.postRequest(["lcode":conectionCode.text!], url: "\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/patient/link", completion: finishRegister)
    }
    
    func finishRegister(data: NSData) {
        print(NSString(data: data, encoding: NSUTF8StringEncoding));
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let status = json["status"] as? String {
                if (status == "success"){
                    if let data = json["data"] as? [String: AnyObject]{
                        if let authcode = data["authcode"] as? String {
                            Constants.saveAuthCode(authcode)
                            Constants.saveType("patient")
                            ServerConnection.postRequest(["uiud": File.readFile("UDID")], url: "\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/patient/device?authcode=\(authcode)", completion: OnFinish)
                            print(authcode)
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc:UIViewController = storyboard.instantiateViewControllerWithIdentifier("PatientInterface")
                                self.presentViewController(vc, animated: false, completion: nil)
                            }
                            
                        }
                    }
                }else {
                    //todo add failed to screen 
                }
            }
        }
        catch {
            print("error serializing JSON: \(error)")
        }

    }
    
    func OnFinish (data: NSData) {
        print(NSString(data: data, encoding: NSUTF8StringEncoding));
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