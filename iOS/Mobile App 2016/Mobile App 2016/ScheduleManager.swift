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
        ServerConnection.getRequest("\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(pid)/schedules?authcode=\(authcode)", completion: populateMeds)
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
    func getSceduleDate(authcode: String, medManager:MedicationManager, completion: (() -> Void)!) {
        for schedule in schedules {
            schedule.getMeds(authcode, medManager: medManager, completion: completion)
        }
    }
    
    func getSchedulePatient(authcode: String, completion: (() -> Void)!) {
        self.completion = completion
        ServerConnection.getRequest("\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/patient/schedules?authcode=\(authcode)", completion: populateMeds)
    }
    func getLateMeds() -> [Schedule]{
        var late = [Schedule]()
        for schedule in schedules {
            let new = schedule.isLate(NSDate())
            if(new.medications.count != 0){
                late.append(new)
            }
        }
        return late
    }
    func sort(){
        let new = schedules.sort(sortFunc)
        schedules = new
        
    }
    func sortFunc(schedule1: Schedule, schedule2: Schedule) -> Bool {
        return schedule1.getDate().compare(schedule2.getDate()) == NSComparisonResult.OrderedAscending
    }
    
    
}