//
//  Patient_MainController.swift
//  Mobile App 2016
//
//  Created by Jack Phillips on 4/1/16.
//  Copyright © 2016 Mamaroneck High School. All rights reserved.
//

import UIKit

class Patient_MainController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var takeNowLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var tableTakeNow = UITableView()
    let textCellIdentifier = "TextCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = true
        //add line seperaters
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.blackColor().CGColor
        border.frame = CGRect(x: 0, y: takeNowLabel.frame.size.height - width, width:  takeNowLabel.frame.size.width, height: takeNowLabel.frame.size.height)
        border.borderWidth = width
        
        let topBorder = CALayer()
        topBorder.frame = CGRectMake(0, 0, timeLabel.frame.size.width, width)
        topBorder.backgroundColor = UIColor.blackColor().CGColor
        
        //med_invitory.layer.addSublayer(border)
        takeNowLabel.layer.addSublayer(topBorder)
        takeNowLabel.layer.addSublayer(border)
        takeNowLabel.layer.masksToBounds = true;
        
        
        var frame: CGRect = self.view.frame
        frame.origin.y += 150
        frame.size.height = frame.size.height * 0.25
        
        tableTakeNow.frame = frame
        tableTakeNow.delegate = self
        tableTakeNow.dataSource = self
        tableTakeNow.rowHeight = 70;
        tableTakeNow.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.setNeedsStatusBarAppearanceUpdate()
        //timeLabel.backgroundColor = UIColor.clearColor()
        //imageView.image = UIImage(named: "Night2.png")
        
        
        
        
        
        
        updateTime()
        self.view.bringSubviewToFront(timeLabel)
        NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(Patient_MainController.updateTime), userInfo: nil, repeats: true)
        
        
        //self.view.addSubview(tableTakeNow)
        
    }
    
    func updateTime(){
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute],fromDate: date);
        
        let hour = components.hour % 12 == 0 ? "12" : "\(components.hour % 12)"
        let minute = components.minute < 10 ? "0\(components.minute)" : "\(components.minute)"
        timeLabel.text = "\(hour):\(minute)"
        print("\(hour):\(minute)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                                                   reuseIdentifier: "cell")
        
        //let row = indexPath.row
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 25)
        cell.textLabel?.text = "Hi"
        return cell;
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
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