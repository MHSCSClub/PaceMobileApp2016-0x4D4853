//
//  ViewController.swift
//  API
//
//  Created by Jack Phillips on 3/4/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("hi")
        let type = Constants.getType()
        print(type)
        let udid = File.readFile("UDID")
        print(udid)
        if(type == "caregiver"){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc:UIViewController = storyboard.instantiateViewControllerWithIdentifier("PatientListViewController")
            self.presentViewController(vc, animated: false, completion: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

