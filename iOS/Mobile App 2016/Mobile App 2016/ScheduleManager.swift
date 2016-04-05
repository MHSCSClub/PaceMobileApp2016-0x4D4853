//
//  ScheduleManager.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 4/2/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//patinet["medid"] as! String

import Foundation

class ScheduleManager {
    var schedules = [Schedule]()
    private var completion: (() -> Void)!
    
    func getMedsPatient(authcode: String, pid: String, completion: (() -> Void)!) {
        self.completion = completion
        ServerConnection.getRequest("http://108.30.55.167/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(pid)/schedules?authcode=\(authcode)", completion: populateMeds)
    }
    
    func populateMeds(data: NSData){
        
        print(NSString(data: data, encoding: NSUTF8StringEncoding));
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let status = json["status"] as? String {
                if (status == "success"){
                    schedules = []
                    if let data = json["data"] as? [[String: AnyObject]]{
                        for schedule in data{
                            schedules.append(Schedule(schid: schedule["schid"] as! String, hours: schedule["hours"] as! String, minutes: schedule["minutes"] as! String))
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
    func getSceduleDate (authcode: String, pid: String, medManager:MedicationManager, completion: (() -> Void)!) {
        for schedule in schedules {
            schedule.getMeds(authcode, pid: pid, medManager: medManager, completion: completion)
        }
    }
    
}