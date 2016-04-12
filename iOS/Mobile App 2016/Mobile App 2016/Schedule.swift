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
        setToCorrectHour()
    }
    func setToCorrectHour(){
        self.hours -= 4;
        if(hours < 0){
            hours += 24
        }
    }
    
    func getMeds(authcode: String, pid: String, medManager: MedicationManager, completion: (() -> Void)!) {
        self.completion = completion
        self.mendicationManager = medManager
        ServerConnection.getRequest("\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/caretaker/patients/\(pid)/schedules/\(schid)?authcode=\(authcode)", completion: populateMeds)
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
                                let date = NSDate()
                                let date2 = date.dateByAddingTimeInterval(-60*60*24)
                                self.taken.append(date2)
                                
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
    
    func getMeds(authcode: String, medManager: MedicationManager, completion: (() -> Void)!) {
        self.completion = completion
        self.mendicationManager = medManager
        ServerConnection.getRequest("\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/patient/schedules/\(schid)?authcode=\(authcode)", completion: populateMeds)
    }
    func getDate() ->NSDate{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day, .Year, .Month], fromDate: NSDate())
        let date = dateFormatter.dateFromString("\(components.year)-\(components.month)-\(components.day) \(hours):\(minutes)")
        return date!
        
    }
    func isLate(today: NSDate) -> Schedule {
        let newSchedule = Schedule(schid: "\(schid)", hours: "\(hours)", minutes: "\(minutes)")
        let dateFormatter = NSDateFormatter()
        let calendar = NSCalendar.currentCalendar()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let components = calendar.components([.Month, .Year, .Day],fromDate: today);
        let takeDate = dateFormatter.dateFromString("\(components.year)-\(components.month)-\(components.day) \(hours):\(minutes)")
        print(takeDate)
        if(medications.count != 0){
            for i in 0...medications.count - 1{
                let calendar = NSCalendar.currentCalendar()
                let components2 = calendar.components([.Day], fromDate: taken[i])
                let day = components2.day
                if(takeDate?.compare(today) == NSComparisonResult.OrderedDescending){
                }else if(day != components.day){
                    print("true")
                    newSchedule.medications.append(medications[i])
                }
            }
        }
        return newSchedule
    }
    
}