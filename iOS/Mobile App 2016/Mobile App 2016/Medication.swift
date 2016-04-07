//
//  Medication.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 3/17/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import Foundation

class Medication {
    var medid:Int
    var name:String
    var dosage:Int
    var remain:Int
    var info: String
    var taken: NSDate = NSDate()
    
    
    init(medid:String, name:String, dosage:String, remain:String, info: String){
        self.medid = Int(medid)!
        self.name = name
        self.dosage = Int(dosage)!
        self.remain = Int(remain)!
        self.info = info
    }
    func createMedication(data:NSData, authcode: String, pid: String, completion: ((NSData) -> Void)!){
        let params = ["name" :name, "dosage": "\(dosage)", "remain": "\(remain)", "info": info]
        print("Here")
        ServerConnection.postFile(params, data: data, url: "http://108.30.55.167/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(pid)/medications?authcode=\(authcode)", completion: completion)
    }
    func takeMedication(){
        
    }
    func getImage(authcode: String, completion: ((NSData) -> Void)){
        ServerConnection.getRequest("http://108.30.55.167/Pace_2016_0x4D4853/Backend/api/patient/medications/\(medid)?authcode=\(authcode)", completion: completion)
    }
}