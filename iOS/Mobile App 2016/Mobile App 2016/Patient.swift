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
    
    init(pid: Int){
        self.pid = pid;
    }
    init(pid: String){
        self.pid = Int(pid)!;
    }
    init(pid: String, name: String, active: String){
        self.pid = Int(pid)!;
        self.name = name;
        self.active = Int(active)!;
    }

}