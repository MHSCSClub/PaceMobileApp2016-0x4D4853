//
//  Popup.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 4/3/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class Popup: UIViewController {
    
    @IBOutlet var addMed: UIButton!
    @IBOutlet var addSchedule: UIButton!
    
    var addMedCall: (() -> Void)!
    var addScheduleCall: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addMedication(sender: AnyObject) {
        addMedCall()
        self.dismissViewControllerAnimated(false, completion: {()->Void in
            print("done");})
    }
    @IBAction func addSchedule(sender: AnyObject) {
        addScheduleCall()
        self.dismissViewControllerAnimated(false, completion: {()->Void in
            print("done");})
    }

}
