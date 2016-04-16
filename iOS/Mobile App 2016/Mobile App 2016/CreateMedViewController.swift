//
//  CreateMedViewController.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 4/1/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//CreateMedViewController

import UIKit

class CreateMedViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var patient:Patient!
    
    @IBOutlet var button: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var medName: UITextField!
    
    @IBOutlet var number: UILabel!
    @IBOutlet var dosage: UISlider!
    @IBOutlet var remain: UITextField!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var info: UITextView!
    
    var callback: (() -> Void)!
    
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        // Do any additional setup after loading the view.
        medName.delegate = self
        
        remain.delegate = self
        info.delegate = self
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(CreateMedViewController.getRideOfKeyboard(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        
        createButton.layer.cornerRadius = 8
        createButton.layer.masksToBounds = true
        createButton.backgroundColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80)
        createButton.layer.borderColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80).CGColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textViewDidBeginEditing(textView: UITextView) {
        self.view.frame.origin.y -= 200
    }
    func getRideOfKeyboard(gesture: UIGestureRecognizer) {
        if(info.isFirstResponder()){
            self.view.frame.origin.y += 200
            info.resignFirstResponder()
        }else if(medName.isFirstResponder()){
            medName.resignFirstResponder()
        }else if(remain.isFirstResponder()){
            remain.resignFirstResponder()
        }
    }
    
    @IBAction func valueChanged(sender: AnyObject) {
        let cool:Int = Int(dosage.value)
        number.text = "\(cool)"
    }
    @IBAction func photoFromLibrary(sender: AnyObject) {
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.cameraCaptureMode = .Photo
        presentViewController(picker, animated: true, completion: nil)
    }
    @IBAction func done () {
        self.resignFirstResponder()
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
        if(imageView.image != nil){
            let data = UIImageJPEGRepresentation(imageView.image!, 0.25)
            if(data != nil){
                Medication(medid: "50", name: medName.text!, dosage: number.text!, remain: remain.text!, info: info.text!).createMedication(data!, authcode: Constants.getAuthCode(), pid: "\(patient.pid)", completion: complete)
            }
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
        navigationController?.popViewControllerAnimated(true)
        if(callback != nil){
            callback()
        }
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