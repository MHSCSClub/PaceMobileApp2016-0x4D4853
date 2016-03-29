//
//  PatientManager.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 3/26/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import Foundation

class PatientManager {
    var patients: [Patient] = []
    private var completion: (() -> Void)!
    
    func getpatients(authcode: String, completion: (() -> Void)!) {
        self.completion = completion
        ServerConnection.getRequest("http://108.30.55.167/Pace_2016_0x4D4853/Backend/api/caretaker/patients?authcode=\(authcode)", completion: populatePatients)
    }
    func populatePatients(data: NSData){
        print(NSString(data: data, encoding: NSUTF8StringEncoding));
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let status = json["status"] as? String {
                if (status == "success"){
                    if let data = json["data"] as? [[String: AnyObject]]{
                        for patinet in data{
                            patients.append(Patient(pid: patinet["pid"] as! String))
                        }
                    }
                }
            }
        }
        catch {
            print("error serializing JSON: \(error)")
        }
        completion()

    }
    
    
}