//
//  MedicationManager.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 4/1/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import Foundation

class MedicationManager {
    var medications: [Medication] = []
    private var completion: (() -> Void)!
    
    func getMeds(authcode: String, pid:String, completion: (() -> Void)!) {
        self.completion = completion
        ServerConnection.getRequest("http://108.30.55.167/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(pid)/medications?authcode=\(authcode)", completion: populateMeds)
    }
    func getMedsPatient(authcode: String, completion: (() -> Void)!) {
        self.completion = completion
        ServerConnection.getRequest("http://108.30.55.167/Pace_2016_0x4D4853/Backend/api/caretaker/patients/medications?authcode=\(authcode)", completion: populateMeds)
    }
    func populateMeds(data: NSData){
        
        print(NSString(data: data, encoding: NSUTF8StringEncoding));
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let status = json["status"] as? String {
                if (status == "success"){
                    medications = []
                    if let data = json["data"] as? [[String: AnyObject]]{
                        for patinet in data{
                            var info = patinet["info"] as? String
                            if(info == nil){
                                info = ""
                            }
                            medications.append(Medication(medid: patinet["medid"] as! String , name: patinet["name"] as! String, dosage: patinet["dosage"] as! String, remain: patinet["remain"] as! String, info: info!))
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
    func getMedFromID(id: Int) -> Medication{
        for med in medications {
            if(med.medid == id){
                return med
            }
        }
        return medications[0]
    }
}