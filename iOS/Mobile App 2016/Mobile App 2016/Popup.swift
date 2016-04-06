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
        addMed.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        addSchedule.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        
        let topBorder = CALayer()
        topBorder.frame = CGRectMake(0, -1, addMed.frame.size.width, 1.0)
        topBorder.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0).CGColor
        
        //med_invitory.layer.addSublayer(border)
        addSchedule.layer.addSublayer(topBorder)
        
        
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
