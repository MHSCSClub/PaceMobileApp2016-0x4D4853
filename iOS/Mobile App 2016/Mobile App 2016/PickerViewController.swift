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
        let type = Constants.getType()
        print(type)
        if(type == "caregiver"){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc:UIViewController = storyboard.instantiateViewControllerWithIdentifier("PatientListViewController")
            self.presentViewController(vc, animated: false, completion: nil)
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

