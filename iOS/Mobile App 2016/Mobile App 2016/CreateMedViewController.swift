//
//  CreateMedViewController.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 4/1/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//CreateMedViewController

import UIKit

class CreateMedViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var patient:Patient!
    
    @IBOutlet var button: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var medName: UITextField!
    @IBOutlet var dosage: UITextField!
    @IBOutlet var remain: UITextField!
    @IBOutlet var info: UITextField!
    
    
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func photoFromLibrary(sender: AnyObject) {
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.cameraCaptureMode = .Photo
        presentViewController(picker, animated: true, completion: nil)
    }
    @IBAction func done () {
        info.resignFirstResponder()
    }
    //delagates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = .ScaleAspectFit
        imageView.image = chosenImage
        button.titleLabel?.text = ""
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func finished(sender: AnyObject) {
        let data = UIImageJPEGRepresentation(imageView.image!, 0.25)
        if(data != nil){
            Medication(medid: "50", name: medName.text!, dosage: dosage.text!, remain: remain.text!, info: info.text!).createMedication(data!, authcode: Constants.getAuthCode(), pid: "\(patient.pid)", completion: complete)
        }
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
    
    @IBAction func cancell(sender: AnyObject) {
        backToScreen()
    }
    func backToScreen () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc:UITabBarController = (storyboard.instantiateViewControllerWithIdentifier("PatientView") as? UITabBarController)!
        let viewcontroller1 = vc.viewControllers![0] as? Caregiver_PatientOverview;
        viewcontroller1?.patient = patient
        let viewcontroller2 = vc.viewControllers![1] as? CareGiver_PatientMed;
        viewcontroller2?.patient = patient
        self.presentViewController(vc, animated: false, completion: nil)
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