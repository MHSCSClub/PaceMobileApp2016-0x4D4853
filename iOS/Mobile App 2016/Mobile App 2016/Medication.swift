//
//  Medication.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 3/17/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import Foundation

class Medication {
    var med:String
    var amountLeft:Int
    var dose:Int
    
    init(med: String, amountLeft:Int, dose:Int){
        self.med = med;
        self.amountLeft = amountLeft;
        self.dose = dose;
        
    }
}