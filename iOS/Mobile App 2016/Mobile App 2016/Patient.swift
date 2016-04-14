//
//  Patient.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 3/26/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import Foundation

class Patient {
    var name: String = ""
    var pid: Int
    var active: Int = 0
    var usability = 0
    var medstatus:Int
    
  
    init(pid: String, name: String, active: String, usability: String, medstatus: String){
        self.pid = Int(pid)!;
        self.name = name;
        self.active = Int(active)!;
        self.usability = Int(usability)!
        self.medstatus = Int(medstatus)!
    }

}