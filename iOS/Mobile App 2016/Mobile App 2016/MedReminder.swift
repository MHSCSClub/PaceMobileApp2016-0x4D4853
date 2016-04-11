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
    @IBOutlet var done: UIButton!
    
    var meds:[Schedule]!
    var medications = [Medication]()
    
    var scheduleid = [Int]()
    var i = 0;
    
    let speech = AVSpeechSynthesizer()
    
    @IBOutlet var header: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getMeds()
        update()
        done.layer.cornerRadius = 8
        done.layer.masksToBounds = true
        done.backgroundColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80)
        done.layer.borderColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.80).CGColor
        
        header.backgroundColor = UIColor(red: 0.13, green: 0.59 , blue: 0.95, alpha: 0.90)
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGrayColor().CGColor
        border.frame = CGRect(x: 10, y: take.frame.size.height - width, width:  take.frame.size.width - 20, height: width)
        border.borderWidth = width
        //take.layer.addSublayer(border)
        
        
        take.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 221,y: 429), radius: CGFloat(19), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath
        //change the fill color
        shapeLayer.fillColor = UIColor(red: 0.96, green: 0.26 , blue: 0.21, alpha: 0.80).CGColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.clearColor().CGColor
        //you can change the line width
        shapeLayer.lineWidth = 3.0
        
        //view.layer.addSublayer(shapeLayer)
        self.view.bringSubviewToFront(take)
        
        //self.view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func done(sender: AnyObject) {
        ServerConnection.postRequest(["medid":"\(medications[i].medid)"], url: "\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/patient/schedules/\(scheduleid[i])/take?authcode=\(Constants.getAuthCode())", completion: next)
        print("\(Constants.baseURL)/Pace_2016_0x4D4853/Backend/api/patient/schedules/\(scheduleid[i])/take?authcode=\(Constants.getAuthCode())")
        
        
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
        take.text = "Take \(medications[i].dosage)0"
        take.text = "Take \(medications[i].dosage)"

        details.text = "\(medications[i].info)"
        details.font = UIFont.systemFontOfSize(20)
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
