//
//  Schedule.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 4/2/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import Foundation

class Schedule {
    var schid: Int
    var hours:Int
    var minutes:Int
    var medications = [Medication]()
    private var completion: (() -> Void)!
    var mendicationManager:MedicationManager!
    var taken = [NSDate]()
    
    init(schid: String, hours:String, minutes:String){
        self.schid = Int(schid)!
        self.hours = Int(hours)!
        self.minutes = Int(minutes)!
    }
    
    func getMeds(authcode: String, pid: String, medManager: MedicationManager, completion: (() -> Void)!) {
        self.completion = completion
        self.mendicationManager = medManager
        ServerConnection.getRequest("http://108.30.55.167/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(pid)/schedules/\(schid)?authcode=\(authcode)", completion: populateMeds)
    }
    
    func populateMeds(data: NSData){
        
        print(NSString(data: data, encoding: NSUTF8StringEncoding));
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let status = json["status"] as? String {
                if (status == "success"){
                    medications = []
                    if let data = json["data"] as? [[String: AnyObject]]{
                        for meds in data{
                            let medication = mendicationManager.getMedFromID(Int(meds["medid"] as! String)!)
                            let taken = meds["taken"] as? String
                            if(taken != nil){
                                self.taken.append(dateFormatter.dateFromString(taken!)!)
                            }else{
                                self.taken.append(NSDate())
                            }
                            medications.append(medication)
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