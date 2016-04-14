//
//  MedInfoViewController.swift
//  Med Together
//
//  Created by Jack Phillips on 4/14/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class MedInfoViewController: UIViewController {
    @IBOutlet var remain: UILabel!
    @IBOutlet var info: UITextView!
    @IBOutlet var refil: UITextField!
    @IBOutlet var image: UIImageView!
    @IBOutlet var navbar: UINavigationItem!
    var patient:Patient!
    var medication:Medication!
    override func viewDidLoad() {
        super.viewDidLoad()
        info.text = medication.info
        remain.text = "Remain \(medication.remain)"
        navbar.title = medication.name
        getPicture()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func updateInfo(sender: AnyObject) {
        ServerConnection.postRequest(["info": info.text!], url: "\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(patient.pid)/medications/\(medication.medid)?authcode=\(Constants.getAuthCode())", completion: done)
        
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
    @IBAction func refil(sender: AnyObject) {
         ServerConnection.postRequest(["remain": remain.text!], url: "\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(patient.pid)/medications/\(medication.medid)?authcode=\(Constants.getAuthCode())", completion: done)
    }
    func getPicture(){
        ServerConnection.getRequest("\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(patient.pid)/medications/\(medication.medid)?authcode=\(Constants.getAuthCode())", completion: updatePicture)
    }
    func updatePicture(data: NSData){
        print("Pictue")
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.image.contentMode = .ScaleAspectFit
            self.image.image = UIImage(data: data)
        }
    }
}
