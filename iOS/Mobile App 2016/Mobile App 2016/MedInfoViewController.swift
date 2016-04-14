//
//  MedInfoViewController.swift
//  Med Together
//
//  Created by Jack Phillips on 4/14/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class MedInfoViewController: UIViewController {
   
    @IBOutlet var info: UITextView!
    @IBOutlet var refil: UITextField!
    @IBOutlet var dosage: UILabel!
    @IBOutlet var remaining: UILabel!
    @IBOutlet var dosagesRemain: UILabel!
    
    @IBOutlet var background: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var navbar: UINavigationItem!
    @IBOutlet var saveButton: UIButton!
    var patient:Patient!
    var medication:Medication!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        info.text = medication.info
        
        remaining.text = "\(medication.remain)"
        dosage.text = "\(medication.dosage)"
        let doseRemain:Int = medication.remain/medication.dosage
        dosagesRemain.text = "\(doseRemain)"
        navbar.title = medication.name
        getPicture()
        self.view.sendSubviewToBack(background)
        remaining.textColor = UIColor.blackColor()
        dosagesRemain.textColor = UIColor.blackColor()
        
        saveButton.layer.cornerRadius = 8
        saveButton.layer.masksToBounds = true
        saveButton.backgroundColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80)
        saveButton.layer.borderColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80).CGColor
        
        if(doseRemain < 2){
            remaining.textColor = UIColor(red: 0.96, green: 0.26 , blue: 0.21, alpha: 0.90)
            dosagesRemain.textColor = UIColor(red: 0.96, green: 0.26 , blue: 0.21, alpha: 0.90)
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func updateInfo(sender: AnyObject) {
        ServerConnection.postRequest(["info": info.text!, "remain": remaining.text!, "dosage": dosage.text!], url: "\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(patient.pid)/medications/\(medication.medid)?authcode=\(Constants.getAuthCode())", completion: done)
        
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
    @IBAction func addDosage(sender: AnyObject) {
        let alert = UIAlertController(title: "Change Dossage", message: "Dosage:", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Dosage"
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            print("Bye")
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            if(Int(textField.text!)! > 10){
                self.dosage.text = "10"
            }else{
                self.dosage.text = textField.text
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    @IBAction func refillpiss(sender: AnyObject) {
        let alert = UIAlertController(title: "Change Pills Remaining", message: "Remain:", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Pills"
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            print("Bye")
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.remaining.text = textField.text
            let remain:Int = Int(textField.text!)!/Int(self.dosage.text!)!
            self.dosagesRemain.text = "\(remain)"
        }))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    @IBAction func PissDosagesLeft(sender: AnyObject) {
        let alert = UIAlertController(title: "Change Doses Remaining", message: "Remain:", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Doses"
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            print("Bye")
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.dosagesRemain.text = textField.text
            let remain:Int = Int(textField.text!)! * Int(self.dosage.text!)!
            self.remaining.text = "\(remain)"
        }))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    //ReturnReload
}
