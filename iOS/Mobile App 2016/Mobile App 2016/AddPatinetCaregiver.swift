//
//  AddPatinetCaregiver.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 3/31/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.

//


import UIKit

class AddPatinetCaregiver: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    @IBOutlet var name: UITextField!
    @IBOutlet var usablity: UIPickerView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var connectionView: UIView!
    @IBOutlet var connectionCode: UILabel!
    @IBOutlet var create: UIButton!
    
    var callback: (() -> Void)!
    
    var usablityOptions = ["1 - Limitied", "2 - Medium", "3 - Full"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usablity.dataSource = self
        usablity.delegate = self
        self.connectionView.hidden = true
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(AddPatinetCaregiver.getRidOfKeyBoard))
    
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        
        self.view.addGestureRecognizer(swipeDown)
        
        createButton.layer.cornerRadius = 8
        createButton.layer.masksToBounds = true
        createButton.backgroundColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80)
        createButton.layer.borderColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80).CGColor
        
        create.layer.cornerRadius = 8
        create.layer.masksToBounds = true
        create.backgroundColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80)
        create.layer.borderColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80).CGColor


        
    }
    @IBAction func nameDone(sender: AnyObject) {
        name.resignFirstResponder()
    }
    func getRidOfKeyBoard(gesture: UIGestureRecognizer){
        name.resignFirstResponder()
    }
    
   
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return usablityOptions.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return usablityOptions[row]
    }
    
    
    @IBAction func create(sender: AnyObject) {
        let usability = usablity.selectedRowInComponent(0)
        ServerConnection.postRequest(["name":name.text!, "usability": "\(usability)"], url: "\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/caretaker/patients?authcode=\(Constants.getAuthCode())", completion: createDone)
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
                                self.connectionCode.text = lcode
                                self.connectionView.hidden = false
                                
                                
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
    @IBAction func done(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
        if(callback != nil){
            callback()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
