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
    
    init(pid: Int){
        self.pid = pid;
    }
    init(pid: String){
        self.pid = Int(pid)!;
    }
}