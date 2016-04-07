//
//  Caregiver_PatientOverview.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 3/17/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit
import AVFoundation

class MedReminder: UIViewController {
    @IBOutlet var Med_Label: UILabel!
    @IBOutlet var take: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var details: UITextView!
    
    var meds:[Schedule]!
    var medications = [Medication]()
    
    var scheduleid = [Int]()
    var i = 0;
    
    let speech = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMeds()
        update()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func done(sender: AnyObject) {
        ServerConnection.postRequest(["medid":"\(medications[i].medid)"], url: "http://108.30.55.167/Pace_2016_0x4D4853/Backend/api/patient/schedules/\(scheduleid[i])/take?authcode=\(Constants.getAuthCode())", completion: next)
        print("http://108.30.55.167/Pace_2016_0x4D4853/Backend/api/patient/schedules/\(scheduleid[i])/take?authcode=\(Constants.getAuthCode())")
        
        
    }
    @IBAction func play(sender: AnyObject) {
        let speechUtterance = AVSpeechUtterance(string: medications[i].info)
        speechUtterance.rate = 0.40
        speech.speakUtterance(speechUtterance)
    }
    func next(data:NSData){
        print(NSString(data: data, encoding: NSUTF8StringEncoding));
        i += 1
        if(i == medications.count){
            NSOperationQueue.mainQueue().addOperationWithBlock {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc:UIViewController = storyboard.instantiateViewControllerWithIdentifier("PatientInterface")
                self.presentViewController(vc, animated: true, completion: nil)
                
            }
        }else{
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.update()
            }
        }
    }
    func getMeds() {
        for schedule in meds {
            for med in schedule.medications {
                medications.append(med)
                scheduleid.append(schedule.schid)
            }
        }
    }
    func update() {
        
        Med_Label.text = "\(medications[i].name)"
        take.text = "Take \(medications[i].dosage)"
        details.text = "\(medications[i].info)"
        details.selectable = false
        medications[i].getImage(Constants.getAuthCode(), completion: updatePicture)
        let speechUtterance = AVSpeechUtterance(string: medications[i].info)
        speechUtterance.rate = 0.40
        speech.speakUtterance(speechUtterance)
        
    }
    func updatePicture(data: NSData){
        print("Pictue")
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.image.contentMode = .ScaleAspectFit
            self.image.image = UIImage(data: data)
        }
    }
  
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
